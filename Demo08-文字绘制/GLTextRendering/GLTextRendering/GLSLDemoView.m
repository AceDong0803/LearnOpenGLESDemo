//
//  GLSLDemoView.m
//  GLSLDemo
//
//  Created by AceDong on 2020/8/28.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "GLSLDemoView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLShaderUtils.h"
#import "TextTexture.h"
#import <GLKit/GLKit.h>



//from bit twiddling hacks
static inline uint32_t nextPowerOfTwo(uint32_t v)
{
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v++;
    return v;
}

static NSString *kDrawText = @"不忘初心，方得始终";

typedef struct
{
    GLKVector3 position;
    GLKVector2 texCoords;
} ADTVertex;


ADTVertex textVertex[6];

@interface  GLSLDemoView()

@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , strong) CAEAGLLayer* mEagLayer;
@property (nonatomic , assign) GLuint       mProgram;

@property (nonatomic , assign) GLuint mColorRenderBuffer;
@property (nonatomic , assign) GLuint mColorFrameBuffer;

@property (nonatomic , assign) TextTexture *mTexture;

@end

@implementation GLSLDemoView

+ (Class)layerClass{
    return [CAEAGLLayer class];
}


- (void)layoutSubviews{
    
    //设置Layer
    self.mEagLayer = (CAEAGLLayer *) self.layer;
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    self.mEagLayer.opaque = YES;
    self.mEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    
    //设置openglES 上下文
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:api];
    
    if (!context) {
        NSLog(@"error to init openglES context");
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"error to set current openglES context");
    }
    self.mContext = context;
    
    //删除之前的render Buffer
    glDeleteBuffers(1, &_mColorFrameBuffer);
    _mColorFrameBuffer = 0;
    
    glDeleteBuffers(1,&_mColorRenderBuffer);
    _mColorRenderBuffer = 0;
    
    
    //Render Buffer
    GLuint renderBuffer;
    glGenRenderbuffers(1, &renderBuffer);
    self.mColorRenderBuffer = renderBuffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.mColorRenderBuffer);
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mEagLayer];
    
    
    //Frame Buffer
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    self.mColorFrameBuffer = frameBuffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.mColorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.mColorRenderBuffer);
    
    
    [self render];
}


- (void)render{
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    
    //加载shader
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    self.mProgram = [GLShaderUtils loadShaders:vertFile fsh:fragFile];
    BOOL islinkProgramSuc = [GLShaderUtils linkProgram:self.mProgram];
    if(islinkProgramSuc){
        NSLog(@"link shader program success");
        glUseProgram(self.mProgram);
    }
    else{
        NSLog(@"link shader program failed");
        return;
    }

    [self drawText:kDrawText font:[UIFont boldSystemFontOfSize:16.0f] color:[UIColor cyanColor]];
    
    [self transfomGLView];
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)drawText:(NSString *)text
            font:(UIFont *)font
           color:(UIColor *)textColor{
    
    //创建文本纹理
    self.mTexture = [self createAndBindTexture:kDrawText font:[UIFont boldSystemFontOfSize:20.0f] color:[UIColor cyanColor]];

    if (!self.mTexture.textureId) {
        return;
    }

    textVertex[0].texCoords = GLKVector2Make(1.0f, 1.0f);
    textVertex[1].texCoords = GLKVector2Make(0.0f, 1.0f);
    textVertex[2].texCoords = GLKVector2Make(1.0f, 0.0f);
    textVertex[3].texCoords = GLKVector2Make(1.0f, 0.0f);
    textVertex[4].texCoords = GLKVector2Make(0.0f, 1.0f);
    textVertex[5].texCoords = GLKVector2Make(0.0f, 0.0f);

    

    float texHeight = self.mTexture.height;
    float texWidth = self.mTexture.width;

    float x = 100;
    float y = 100;
    
    float minX = 1 - ((x + texWidth) * 2)/ self.frame.size.width;
    float maxX = 1 - (x  * 2)/ self.frame.size.width;
    
    float minY = 1 - ((y + texHeight) * 2)/ self.frame.size.height;
    float maxY = 1 - (y * 2)/ self.frame.size.height;
    

    textVertex[0].position  = GLKVector3Make(maxX, maxY ,0.0f);
    textVertex[1].position  = GLKVector3Make(minX, maxY ,0.0f);
    textVertex[2].position  = GLKVector3Make(maxX, minY ,0.0f);
    textVertex[3].position  = GLKVector3Make(maxX, minY ,0.0f);
    textVertex[4].position  = GLKVector3Make(minX, maxY ,0.0f);
    textVertex[5].position  = GLKVector3Make(minX, minY ,0.0f);


    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, 6 * sizeof(ADTVertex), textVertex, GL_STATIC_DRAW);

    GLuint position = glGetAttribLocation(self.mProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(ADTVertex), NULL + offsetof(ADTVertex, position));
    glEnableVertexAttribArray(position);

    GLuint textCoor = glGetAttribLocation(self.mProgram, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(ADTVertex), NULL + offsetof(ADTVertex, texCoords));
    glEnableVertexAttribArray(textCoor);
    
}

- (TextTexture *)createAndBindTexture:(NSString *)text
                                 font:(UIFont *)font
                                color:(UIColor *)textColor{

    CGSize renderedSize = [text sizeWithAttributes:@{NSFontAttributeName: font}];

    const uint32_t height = nextPowerOfTwo((int)renderedSize.height);
    const uint32_t width = nextPowerOfTwo((int) renderedSize.width);

    //绘制文字图片纹理
    const int bitsPerElement = 8;
    int sizeInBytes = height * width * 4;
    int texturePitch = width * 4;
    uint8_t *data = (uint8_t *)malloc(sizeInBytes * sizeof(uint8_t));
    memset(data, 0x00, sizeInBytes);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerElement, texturePitch, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    CGColorRef color = textColor.CGColor;
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetFillColorWithColor(context, color);
    CGContextTranslateCTM(context, 0.0f, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    UIGraphicsPushContext(context);
    [text drawInRect:CGRectMake(0, 0, width, height) withAttributes:@{NSFontAttributeName: font}];
    UIGraphicsPopContext();
    
//    CGImageRef contextImage = CGBitmapContextCreateImage(context); //debug texture
//    UIImage *fontImage = [UIImage imageWithCGImage:contextImage];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    free(data);

    TextTexture *textTexture = [[TextTexture alloc]init];
    textTexture.height = height;
    textTexture.width = width;
    textTexture.textureId = textureID;

    return textTexture;
}



- (void)transfomGLView{
    
    GLuint rotate = glGetUniformLocation(self.mProgram, "rotateMatrix");
    
    float radians = 0 * 3.14159f / 180.0f; //旋转180度让图片正向
    
    float s = sin(radians);
    float c = cos(radians);
    
    //z轴旋转矩阵
    GLfloat zRotation[16] = {
        c,-s,0,0,
        s,c,0,0,
        0,0,1,0,
        0,0,0,1
    };
    
    //设置旋转矩阵
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    
    
}


- (void)dealloc
{
    if (self.mColorFrameBuffer) {
        glDeleteBuffers(1, &_mColorFrameBuffer);
        self.mColorFrameBuffer = 0;
    }
    
    if (self.mColorRenderBuffer) {
        glDeleteBuffers(1, &_mColorRenderBuffer);
        self.mColorRenderBuffer = 0;
    }
    
    if ([EAGLContext currentContext] == self.mContext) {
        [EAGLContext setCurrentContext:nil];
    }
    
}








@end
