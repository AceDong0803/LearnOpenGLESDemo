//
//  GLPaintView.m
//  GLPaintDemo
//
//  Created by AceDong on 2020/8/30.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "GLPaintView.h"
#import "GLTools.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>
#import "GLTools.h"
#import <sys/stat.h>
#import "GLFileTools.h"


#define kBrushOpacity        (1.0 / 3.0)
#define kBrushPixelStep        3
#define kBrushScale            2

enum {
    PROGRAM_POINT,
    NUM_PROGRAMS
};

enum {
    UNIFORM_MVP,
    UNIFORM_POINT_SIZE,
    UNIFORM_VERTEX_COLOR,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};

enum {
    ATTRIB_VERTEX,
    NUM_ATTRIBS
};


typedef struct {
    char *vert, *frag;
    GLint uniform[NUM_UNIFORMS];
    GLuint id;
} programInfo_t;


programInfo_t program[NUM_PROGRAMS] = {
    { "point.vsh",   "point.fsh" },
};

typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;

@interface GLPaintView (){
    GLint backingWidth;
    GLint backingHeight;
    EAGLContext *context;
    GLuint viewRenderbuffer, viewFramebuffer;
    textureInfo_t brushTexture;
    GLfloat brushColor[4];
    Boolean    firstTouch;
    Boolean needsErase;
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint shaderProgram;
    GLuint vboId;
    BOOL initialized;
}

@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;

@end

@implementation GLPaintView

@synthesize  location;
@synthesize  previousLocation;


+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpGLEnv];
    }
    return self;
}

- (void)dealloc
{
    if (viewFramebuffer) {
        glDeleteFramebuffers(1, &viewFramebuffer);
        viewFramebuffer = 0;
    }
    if (viewRenderbuffer) {
        glDeleteRenderbuffers(1, &viewRenderbuffer);
        viewRenderbuffer = 0;
    }
    if (brushTexture.id) {
        glDeleteTextures(1, &brushTexture.id);
        brushTexture.id = 0;
    }
    if (vboId) {
        glDeleteBuffers(1, &vboId);
        vboId = 0;
    }
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
}

- (void)setUpGLEnv{
    
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context || ![EAGLContext setCurrentContext:context]) {
        NSLog(@"init OpenGL Context Failed");
    }
    self.contentScaleFactor = [[UIScreen mainScreen] scale];
    needsErase = YES;
    
}


- (void)layoutSubviews{
    [super layoutSubviews];
    [EAGLContext setCurrentContext:context];
    if (!initialized) {
        initialized = [self setUpGL];
    }
    else {
        [self resizeFromLayer:(CAEAGLLayer*)self.layer];
    }
    if (needsErase) {
        [self erase];
        needsErase = NO;
    }
}


- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer");
        return NO;
    }
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    glUseProgram(program[PROGRAM_POINT].id);
    glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
    glViewport(0, 0, backingWidth, backingHeight);
    return YES;
}



- (BOOL)setUpGL{
        glGenFramebuffers(1, &viewFramebuffer);
        glGenRenderbuffers(1, &viewRenderbuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        {
            NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
            return NO;
        }
        glViewport(0, 0, backingWidth, backingHeight);
        glGenBuffers(1, &vboId);
        brushTexture = [self textureFromName:@"Particle.png"];
        [self setupShaders];
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        return YES;
}


- (textureInfo_t)textureFromName:(NSString *)name
{
    CGImageRef brushImage = [UIImage imageNamed:name].CGImage;
    size_t width = CGImageGetWidth(brushImage);
    size_t height = CGImageGetHeight(brushImage);
    if(brushImage) {
        GLubyte *brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
        CGContextRef  brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
        CGContextRelease(brushContext);
        GLuint texId;
        glGenTextures(1, &texId);
        glBindTexture(GL_TEXTURE_2D, texId);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        free(brushData);
        textureInfo_t   texture;
        texture.id = texId;
        texture.width = (int)width;
        texture.height = (int)height;
        return texture;
    }
    
    textureInfo_t nullTexture = {0,0,0};
    return nullTexture;
}


- (void)setupShaders
{
    for (int i = 0; i < NUM_PROGRAMS; i++)
    {
        char *vsrc = [GLFileTools getShaderWithName:[NSString stringWithCString:program[i].vert encoding:NSUTF8StringEncoding]];
        char *fsrc = [GLFileTools getShaderWithName:[NSString stringWithCString:program[i].frag encoding:NSUTF8StringEncoding]];
        GLsizei attribCt = 0;
        GLchar *attribUsed[NUM_ATTRIBS];
        GLint attrib[NUM_ATTRIBS];
        GLchar *attribName[NUM_ATTRIBS] = {
            "inVertex",
        };
        const GLchar *uniformName[NUM_UNIFORMS] = {
            "MVP", "pointSize", "vertexColor", "texture",
        };
        
        for (int j = 0; j < NUM_ATTRIBS; j++)
        {
            if (strstr(vsrc, attribName[j]))
            {
                attrib[attribCt] = j;
                attribUsed[attribCt++] = attribName[j];
            }
        }
        glueCreateProgram(vsrc, fsrc,
                          attribCt, (const GLchar **)&attribUsed[0], attrib,
                          NUM_UNIFORMS, &uniformName[0], program[i].uniform,
                          &program[i].id);

        if (i == PROGRAM_POINT)
        {
            glUseProgram(program[PROGRAM_POINT].id);
            glUniform1i(program[PROGRAM_POINT].uniform[UNIFORM_TEXTURE], 0);
            GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
            GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
            GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
            glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
            glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], brushTexture.width / kBrushScale);
            glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
        }
    }
    glError();
}

- (void)erase
{
    [EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
    static GLfloat *vertexBuffer = NULL;
    static NSUInteger vertexMax = 64;
    NSUInteger vertexCount = 0;
    NSUInteger count = 0;
    NSUInteger i = 0;
    [EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
    
    CGFloat scale = self.contentScaleFactor;
    start.x *= scale;
    start.y *= scale;
    end.x *= scale;
    end.y *= scale;
    
    if(vertexBuffer == NULL){
        vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
    }
    
    
    count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
    
    for(i = 0; i < count; ++i) {
        if(vertexCount == vertexMax) {
            vertexMax = 2 * vertexMax;
            vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
        }
        vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
        vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        vertexCount += 1;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, vertexCount*2*sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    glUseProgram(program[PROGRAM_POINT].id);
    glDrawArrays(GL_POINTS, 0, (int)vertexCount);
    
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    UITouch *touch = [[event touchesForView:self] anyObject];
    firstTouch = YES;
    location = [touch locationInView:self];
    location.y = bounds.size.height - location.y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    UITouch *touch = [[event touchesForView:self] anyObject];
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    } else {
        location = [touch locationInView:self];
        location.y = bounds.size.height - location.y;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    }
    [self renderLineFromPoint:previousLocation toPoint:location];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    UITouch *touch = [[event touchesForView:self] anyObject];
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
        [self renderLineFromPoint:previousLocation toPoint:location];
    }
}

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    brushColor[0] = red * kBrushOpacity;
    brushColor[1] = green * kBrushOpacity;
    brushColor[2] = blue * kBrushOpacity;
    brushColor[3] = kBrushOpacity;
    if (initialized) {
        glUseProgram(program[PROGRAM_POINT].id);
        glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
    }
}



@end

