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

typedef struct
{
    float position[4];
    float textureCoordinate[2];
} CustomVertex;

enum{
    Saturation_Position = 0,
    Saturation_InputTextTureCoordinate,
    Saturation_InputImageTextTure,
    Saturation_SaturationValue,
    Num_Saturation
};
GLint SaturationGLValues[Num_Saturation];


enum{
    Temperature_Position = 0,
    Temperature_InputTextTureCoordinate,
    Temperature_InputImageTextTure,
    Temperature_TemperatureValue,
    Num_Temperature
};
GLint TemperatureGLValues[Num_Temperature];

@interface  GLSLDemoView(){
    
    GLuint _mSaturationProgram;
    GLuint _mTemperatureProgram;
    
    GLuint _mSaturationFrameBuffer;
    GLuint _mTemperatureRenderBuffer;
    GLuint _mTemperatureFrameBuffer;
    
    GLuint _saturationTexture;
    GLuint _tempTexture;
    
    
}

@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , strong) CAEAGLLayer* mEagLayer;
@property (nonatomic, strong) UIImage *image;

@end

@implementation GLSLDemoView


+ (Class)layerClass{
    return [CAEAGLLayer class];
}


- (void)setupOpenGL{
    
    _saturation = 0.5;
    _temperature = 0.5;
    //设置Layer
    self.mEagLayer = (CAEAGLLayer *) self.layer;
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
    
    
    if (_mTemperatureRenderBuffer) {
        glDeleteRenderbuffers(1, &_mTemperatureRenderBuffer);
        _mTemperatureRenderBuffer = 0;
    }

    glGenRenderbuffers(1, &_mTemperatureRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _mTemperatureRenderBuffer);
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mEagLayer];
    
    
    
    if (_mTemperatureFrameBuffer) {
        glDeleteRenderbuffers(1, &_mTemperatureFrameBuffer);
        _mTemperatureFrameBuffer = 0;
    }
    
    //Frame Buffer
    glGenFramebuffers(1, &_mTemperatureFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _mTemperatureFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _mTemperatureRenderBuffer);
    

    
    
    //加载temperature shader
    [self compileTemperatureShader];
    
    //加载saturation shader
    [self compileSaturationShader];
    
    [self bindVertexAndTexture];
    
    NSError *error;
    NSAssert1([self checkFramebuffer:&error], @"%@",error.userInfo[@"ErrorMessage"]);
    
}

- (void)layoutSubviews{
    
}


- (void)layoutGLViewWithImage:(UIImage *)image{
    self.image = image;
    [self setupOpenGL];
    [self render];
    
}

- (void)render{
    CGFloat scale = self.contentScaleFactor;
    //绘制饱和度滤镜
    glUseProgram(_mSaturationProgram);
    glBindFramebuffer(GL_FRAMEBUFFER, _mSaturationFrameBuffer);
    
    
    glClearColor(0, 0, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width * scale, self.frame.size.height * scale);
    glUniform1i(SaturationGLValues[Saturation_InputImageTextTure], 1);
    glUniform1f(SaturationGLValues[Saturation_SaturationValue], _saturation);

    glVertexAttribPointer(SaturationGLValues[Saturation_Position], 4, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), 0);
    glVertexAttribPointer(SaturationGLValues[Saturation_InputTextTureCoordinate], 2, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), (GLvoid *)(sizeof(float) * 4));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //绘制temp滤镜
    glUseProgram(_mTemperatureProgram);
    glBindFramebuffer(GL_FRAMEBUFFER, _mTemperatureFrameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _mTemperatureRenderBuffer);
    glViewport(0, 0, self.frame.size.width * scale, self.frame.size.height * scale);
    glClearColor(1, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glUniform1i(TemperatureGLValues[Temperature_InputImageTextTure], 0);
    glUniform1f(TemperatureGLValues[Temperature_TemperatureValue], _temperature);

    glVertexAttribPointer(TemperatureGLValues[Temperature_Position], 4, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), 0);
    glVertexAttribPointer(TemperatureGLValues[Temperature_InputTextTureCoordinate], 2, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), (GLvoid *)(sizeof(float) * 4));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
    
}

- (void)compileSaturationShader{
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"saturation" ofType:@"fsh"];
    _mSaturationProgram = [GLShaderUtils loadShaders:vertFile fsh:fragFile];
    BOOL islinkProgramSuc = [GLShaderUtils linkProgram:_mSaturationProgram];
    if(islinkProgramSuc){
        NSLog(@"link saturation shader program success");
        glUseProgram(_mSaturationProgram);
    }
    else{
        NSLog(@"link saturation shader program failed");
        return;
    }
    SaturationGLValues[Saturation_Position] = glGetAttribLocation(_mSaturationProgram, "position");
    SaturationGLValues[Saturation_InputTextTureCoordinate] = glGetAttribLocation(_mSaturationProgram, "inputTextureCoordinate");
    SaturationGLValues[Saturation_InputImageTextTure] = glGetUniformLocation(_mSaturationProgram, "inputImageTexture");
    SaturationGLValues[Saturation_SaturationValue] = glGetUniformLocation(_mSaturationProgram, "saturation");
    glEnableVertexAttribArray(SaturationGLValues[Saturation_Position]);
    glEnableVertexAttribArray(SaturationGLValues[Saturation_InputTextTureCoordinate]);
}

- (void)compileTemperatureShader{
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"temperature" ofType:@"fsh"];
    _mTemperatureProgram = [GLShaderUtils loadShaders:vertFile fsh:fragFile];
    BOOL islinkProgramSuc = [GLShaderUtils linkProgram:_mTemperatureProgram];
    if(islinkProgramSuc){
        NSLog(@"link temperature shader program success");
        glUseProgram(_mTemperatureProgram);
    }
    else{
        NSLog(@"link temperature shader program failed");
        return;
    }
    TemperatureGLValues[Temperature_Position] = glGetAttribLocation(_mTemperatureProgram, "position");
    TemperatureGLValues[Temperature_InputTextTureCoordinate] = glGetAttribLocation(_mTemperatureProgram, "inputTextureCoordinate");
    TemperatureGLValues[Temperature_InputImageTextTure] = glGetUniformLocation(_mTemperatureProgram, "inputImageTexture");
    TemperatureGLValues[Temperature_TemperatureValue] = glGetUniformLocation(_mTemperatureProgram, "temperature");
    glEnableVertexAttribArray(TemperatureGLValues[Temperature_Position]);
    glEnableVertexAttribArray(TemperatureGLValues[Temperature_InputTextTureCoordinate]);
}

- (void)bindVertexAndTexture{
    
    static const CustomVertex vertices[] =
    {
        { .position = { -1.0, -1.0, 0, 1 }, .textureCoordinate = { 0.0, 0.0 } },
        { .position = {  1.0, -1.0, 0, 1 }, .textureCoordinate = { 1.0, 0.0 } },
        { .position = { -1.0,  1.0, 0, 1 }, .textureCoordinate = { 0.0, 1.0 } },
        { .position = {  1.0,  1.0, 0, 1 }, .textureCoordinate = { 1.0, 1.0 } }
    };
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    [self setupTexture];
    
}

- (void)setupTexture{
    
    glGenFramebuffers(1, &_mSaturationFrameBuffer);
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &_saturationTexture);
    glBindTexture(GL_TEXTURE_2D, _saturationTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.frame.size.width * self.contentScaleFactor, self.frame.size.height * self.contentScaleFactor, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glBindFramebuffer(GL_FRAMEBUFFER, _mSaturationFrameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _saturationTexture, 0);
    
    _tempTexture = [GLShaderUtils loadTexture:self.image activeTexture:GL_TEXTURE1];
    
}

- (BOOL)checkFramebuffer:(NSError *__autoreleasing *)error {
    // 检查 framebuffer 是否创建成功
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSString *errorMessage = nil;
    BOOL result = NO;
    switch (status)
    {
        case GL_FRAMEBUFFER_UNSUPPORTED:
            errorMessage = @"framebuffer不支持该格式";
            result = NO;
            break;
        case GL_FRAMEBUFFER_COMPLETE:
            NSLog(@"framebuffer 创建成功");
            result = YES;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            errorMessage = @"Framebuffer不完整 缺失组件";
            result = NO;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
            errorMessage = @"Framebuffer 不完整, 附加图片必须要指定大小";
            result = NO;
            break;
        default:
            // 一般是超出GL纹理的最大限制
            errorMessage = @"未知错误 error !!!!";
            result = NO;
            break;
    }
    NSLog(@"%@",errorMessage ? errorMessage : @"");
    *error = errorMessage ? [NSError errorWithDomain:@"com.Yue.error"
                                                code:status
                                            userInfo:@{@"ErrorMessage" : errorMessage}] : nil;
    return result;
}



- (void)setTemperature:(CGFloat)temperature{
    _temperature = temperature;
    [self render];
}


- (void)setSaturation:(CGFloat)saturation{
    _saturation = saturation;
    [self render];
}

- (void)dealloc
{
    if (_mSaturationFrameBuffer) {
        glDeleteBuffers(1, &_mSaturationFrameBuffer);
        _mSaturationFrameBuffer = 0;
    }
    
    
    if (_mTemperatureFrameBuffer) {
        glDeleteBuffers(1, &_mTemperatureFrameBuffer);
        _mTemperatureFrameBuffer = 0;
    }
    
    if (_mTemperatureRenderBuffer) {
        glDeleteBuffers(1, &_mTemperatureRenderBuffer);
        _mTemperatureRenderBuffer = 0;
    }
    
    if ([EAGLContext currentContext] == self.mContext) {
        [EAGLContext setCurrentContext:nil];
    }
    
}

@end
