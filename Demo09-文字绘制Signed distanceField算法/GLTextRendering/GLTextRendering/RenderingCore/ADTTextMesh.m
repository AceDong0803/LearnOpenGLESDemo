//
//  ADTTextMesh.m
//  GLTextRendering
//
//  Created by AceDong on 2020/9/8.
//  Copyright © 2020 AceDong. All rights reserved.
//


#import "ADTTextMesh.h"
#import "ADTextType.h"
#import <OpenGLES/ES2/gl.h>
#import "GLShaderUtils.h"
@import CoreText;

typedef void (^ADTGlyphPositionEnumerationBlock)(CGGlyph glyph,
                                                 NSInteger glyphIndex,
                                                 CGRect glyphBounds);

@implementation ADTTextMesh

@synthesize vertexBuffer=_vertexBuffer;
@synthesize indexBuffer=_indexBuffer;

- (instancetype)initWithString:(NSString *)string
                        inRect:(CGRect)rect
                      withFontAtlas:(ADTFontAtlas *)fontAtlas
                        atSize:(CGFloat)fontSize
{
    if ((self = [super init]))
    {
        [self buildMeshWithString:string inRect:rect withFont:fontAtlas atSize:fontSize];
    }
    return self;
}

- (void)buildMeshWithString:(NSString *)string
                     inRect:(CGRect)rect
                   withFont:(ADTFontAtlas *)fontAtlas
                     atSize:(CGFloat)fontSize
{
    UIFont *font = [fontAtlas.parentFont fontWithSize:fontSize];
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    CFRange stringRange = CFRangeMake(0, attrString.length);
    CGPathRef rectPath = CGPathCreateWithRect(rect, NULL);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, stringRange, rectPath, NULL);

    __block CFIndex frameGlyphCount = 0;
    NSArray *lines = (__bridge id)CTFrameGetLines(frame);
    [lines enumerateObjectsUsingBlock:^(id lineObject, NSUInteger lineIndex, BOOL *stop) {
        frameGlyphCount += CTLineGetGlyphCount((__bridge CTLineRef)lineObject);
    }];

    const size_t vertexCount = frameGlyphCount * 4;
    const size_t indexCount = frameGlyphCount * 6;
    ADTVertex *vertices = malloc(vertexCount * sizeof(ADTVertex));
    ADTIndexType *indices = malloc(indexCount * sizeof(ADTIndexType));

    __block ADTIndexType v = 0, i = 0;
    [self enumerateGlyphsInFrame:frame block:^(CGGlyph glyph, NSInteger glyphIndex, CGRect glyphBounds) {
        if (glyph >= fontAtlas.glyphDescriptors.count)
        {
            NSLog(@"Font atlas has no entry corresponding to glyph #%d; Skipping...", glyph);
            return;
        }
        ADTGlyphDescriptor *glyphInfo = fontAtlas.glyphDescriptors[glyph];
        float minX =  CGRectGetMinX(glyphBounds) / rect.size.width * 2.0f;
        float maxX =  CGRectGetMaxX(glyphBounds) / rect.size.width * 2.0f;
        float minY =  CGRectGetMinY(glyphBounds) / rect.size.height * 2.0f;
        float maxY =  CGRectGetMaxY(glyphBounds) / rect.size.height * 2.0f;
        
        minX -= 1;
        maxX -= 1;
        minY = 1 - minY;
        maxY = 1 - maxY;
        
        float minS = glyphInfo.topLeftTexCoord.x ;
        float maxS = glyphInfo.bottomRightTexCoord.x ;
        float minT =  glyphInfo.topLeftTexCoord.y ;
        float maxT =  glyphInfo.bottomRightTexCoord.y ;
        
        vertices[v++] = (ADTVertex){ { minX, maxY, 0 , 1.0}, { minS,  maxT} };
        vertices[v++] = (ADTVertex){ { minX, minY, 0 , 1.0}, { minS, minT  } };
        vertices[v++] = (ADTVertex){ { maxX, minY, 0 , 1.0}, { maxS, minT} };
        vertices[v++] = (ADTVertex){ { maxX, maxY, 0 , 1.0}, { maxS, maxT } };
        indices[i++] = (GLuint)glyphIndex * 4;
        indices[i++] = (GLuint)glyphIndex * 4 + 1;
        indices[i++] = (GLuint)glyphIndex * 4 + 2;
        indices[i++] = (GLuint)glyphIndex * 4 + 2;
        indices[i++] = (GLuint)glyphIndex * 4 + 3;
        indices[i++] = (GLuint)glyphIndex * 4;
    }];
  
    
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
    }
    
    if (_indexBuffer) {
        glDeleteBuffers(1, &_indexBuffer);
    }

    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(ADTVertex), vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER,  indexCount * sizeof(ADTIndexType), indices, GL_STATIC_DRAW);
    self.indexCount = (int)indexCount;
    self.vertexCount = (int)vertexCount;
    
    glError()
    
    free(indices);
    free(vertices);
    CFRelease(frame);
    CFRelease(framesetter);
    CFRelease(rectPath);
}

- (void)enumerateGlyphsInFrame:(CTFrameRef)frame
                         block:(ADTGlyphPositionEnumerationBlock)block
{
    if (!block)
        return;

    CFRange entire = CFRangeMake(0, 0);

    CGPathRef framePath = CTFrameGetPath(frame);
    CGRect frameBoundingRect = CGPathGetPathBoundingBox(framePath);

    NSArray *lines = (__bridge id)CTFrameGetLines(frame);

    CGPoint *lineOriginBuffer = malloc(lines.count * sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, entire, lineOriginBuffer);

    __block CFIndex glyphIndexInFrame = 0;

    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();

    [lines enumerateObjectsUsingBlock:^(id lineObject, NSUInteger lineIndex, BOOL *stop) {
        CTLineRef line = (__bridge CTLineRef)lineObject;
        CGPoint lineOrigin = lineOriginBuffer[lineIndex];

        NSArray *runs = (__bridge id)CTLineGetGlyphRuns(line);
        [runs enumerateObjectsUsingBlock:^(id runObject, NSUInteger rangeIndex, BOOL *stop) {
            CTRunRef run = (__bridge CTRunRef)runObject;

            size_t glyphCount = CTRunGetGlyphCount(run);

            CGGlyph *glyphBuffer = malloc(glyphCount * sizeof(CGGlyph));
            CTRunGetGlyphs(run, entire, glyphBuffer);

            CGPoint *positionBuffer = malloc(glyphCount * sizeof(CGPoint));
            CTRunGetPositions(run, entire, positionBuffer);

            for (size_t glyphIndex = 0; glyphIndex < glyphCount; ++glyphIndex)
            {
                CGGlyph glyph = glyphBuffer[glyphIndex];
                CGPoint glyphOrigin = positionBuffer[glyphIndex];
                CGRect glyphRect = CTRunGetImageBounds(run, context, CFRangeMake(glyphIndex, 1));
                CGFloat boundsTransX = frameBoundingRect.origin.x + lineOrigin.x;
                CGFloat boundsTransY = CGRectGetHeight(frameBoundingRect) + frameBoundingRect.origin.y - lineOrigin.y + glyphOrigin.y;
                CGAffineTransform pathTransform = CGAffineTransformMake(1, 0, 0, -1, boundsTransX, boundsTransY);
                glyphRect = CGRectApplyAffineTransform(glyphRect, pathTransform);
                block(glyph, glyphIndexInFrame, glyphRect);

                ++glyphIndexInFrame;
            }

            free(positionBuffer);
            free(glyphBuffer);
        }];
    }];
    
    UIGraphicsEndImageContext();
}


- (void)releaseBuffer
{
    if (self.indexBuffer) {
        glDeleteBuffers(1, &_indexBuffer);
    }


    if (self.vertexBuffer) {
        glDeleteBuffers(1, &_indexBuffer);
    }
}


@end
