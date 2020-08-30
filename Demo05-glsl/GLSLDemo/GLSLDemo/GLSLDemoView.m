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

@interface  GLSLDemoView()

@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , strong) CAEAGLLayer* mEagLayer;
@property (nonatomic , assign) GLuint       mProgram;

@property (nonatomic , assign) GLuint mColorRenderBuffer;
@property (nonatomic , assign) GLuint mColorFrameBuffer;



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

    
  
    [self bindVertexAndTexture];
    
    [self transfomGLView];
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}



- (void)bindVertexAndTexture{
    
    GLfloat attrArr[] =
    {
        1.0f, 1.0f, 0.0f,      1.0f, 1.0f,
         -1.0f, 1.0f, 0.0f,     0.0f, 1.0f,
         1.0f, -1.0f, 0.0f,     1.0f, 0.0f,
        1.0f, -1.0f, 0.0f,     1.0f, 0.0f,
        -1.0f, 1.0f, 0.0f,     0.0f, 1.0f,
        -1.0f, -1.0f, 0.0f,    0.0f, 0.0f,
    };
    
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.mProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint textCoor = glGetAttribLocation(self.mProgram, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
    
    [GLShaderUtils loadTexture:@"Demo.jpg"];
    
}

- (void)transfomGLView{
    
    GLuint rotate = glGetUniformLocation(self.mProgram, "rotateMatrix");
    
    float radians = 180 * 3.14159f / 180.0f; //旋转180度让图片正向
    
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
