//
//  ADTRenderLayerView.m
//  GLTextRendering
//
//  Created by AceDong on 2020/9/8.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "ADTRenderLayerView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLShaderUtils.h"
#import "ADTFontAtlas.h"
#import "ADTTextMesh.h"
#import "ADTextType.h"
//#import "ADTMathUtilities.h"




#define ADT_FORCE_REGENERATE_FONT_ATLAS 1

static NSString *const ADTFontName = @"HoeflerText-Regular";
//static NSString *const ADTSampleText = @"My text Rendering Demo So Difficult";
static NSString *const ADTSampleText = @"It was the best of times, it was the worst of times, "
"it was the age of wisdom, it was the age of foolishness...\n\n"
"Все счастливые семьи похожи друг на друга, "
"каждая несчастливая семья несчастлива по-своему.";
static float ADTFontAtlasSize = 2048;
static float ADTFontDisplaySize = 30;

@interface  ADTRenderLayerView(){
    GLfloat bgColor[4];
    GLuint _textureId;
}

@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , strong) CAEAGLLayer* mEagLayer;
@property (nonatomic , assign) GLuint       mProgram;

@property (nonatomic , assign) GLuint mColorRenderBuffer;
@property (nonatomic , assign) GLuint mColorFrameBuffer;

@property (nonatomic, strong) ADTFontAtlas *fontAtlas;
@property (nonatomic, strong) ADTTextMesh *textMesh;

@property (nonatomic , strong) CADisplayLink *mDisplayLink;


@end

@implementation ADTRenderLayerView


+ (Class)layerClass{
    return [CAEAGLLayer class];
}




- (void)layoutSubviews{
    [self viewRender];
}

- (void)viewRender
{
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
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);
    glDepthFunc(GL_LESS);
    [self renderOpenGL];
    
}


- (void)renderOpenGL{
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
    [self updateTranslateUniForms];
    
    
    bgColor[0] = 0.1;
    bgColor[1] = 0.1;
    bgColor[2] = 0.1;
    bgColor[3] = 1.0f;
    GLuint colorLocation = glGetUniformLocation(self.mProgram, "vertexColor");
    glUniform4fv(colorLocation, 1, bgColor);
    
    
    GLuint textTureLocation = glGetUniformLocation(self.mProgram, "colorMap");
    glUniform1i(textTureLocation, 0);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, self.textMesh.vertexBuffer);
    GLuint position = glGetAttribLocation(self.mProgram, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 4, GL_FLOAT, GL_FALSE, sizeof(ADTVertex),NULL + offsetof(ADTVertex, position));


    GLuint textCoor = glGetAttribLocation(self.mProgram, "textCoordinate");
    glEnableVertexAttribArray(textCoor);
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(ADTVertex), NULL + offsetof(ADTVertex, texCoords));


    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.textMesh.indexBuffer);
    glDrawElements(GL_TRIANGLES, self.textMesh.indexCount, GL_UNSIGNED_INT, 0);

    glError()
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (NSURL *)documentsURL
{
    NSArray *candidates = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [candidates firstObject];
    return [NSURL fileURLWithPath:documentsPath isDirectory:YES];
}


- (void)bindVertexAndTexture{
    
    //绑定字体atlas的SDF纹理
    [self buildFontAtlas];
    
    //渲染文本mesh
    [self buildTextMesh];

}



- (void)buildFontAtlas
{
    NSURL *fontURL = [[self.documentsURL URLByAppendingPathComponent:ADTFontName] URLByAppendingPathExtension:@"sdff"];
    
#if !ADT_FORCE_REGENERATE_FONT_ATLAS
    _fontAtlas = [NSKeyedUnarchiver unarchiveObjectWithFile:fontURL.path];
#endif
    
    if (!_fontAtlas)
    {
        UIFont *font = [UIFont fontWithName:ADTFontName size:32];
        _fontAtlas = [[ADTFontAtlas alloc] initWithFont:font textureSize:ADTFontAtlasSize];
        [NSKeyedArchiver archiveRootObject:_fontAtlas toFile:fontURL.path];
    }
    float fw = ADTFontAtlasSize, fh = ADTFontAtlasSize;
    
    //绑定纹理
    glGenTextures(1, &_textureId);
    glBindTexture(GL_TEXTURE_2D, _textureId);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, fw, fh, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, _fontAtlas.textureData.bytes);
    glError()
    
    
}


- (void)buildTextMesh{
    CGRect textRect = self.frame;
    //使用core text获取文字glyph mesh
    self.textMesh = [[ADTTextMesh alloc] initWithString:ADTSampleText
                                             inRect:textRect
                                          withFontAtlas:self.fontAtlas
                                             atSize:ADTFontDisplaySize];
}


- (void)updateTranslateUniForms{
    
    GLuint rotate = glGetUniformLocation(self.mProgram, "rotateMatrix");
    
    //z轴旋转矩阵
    GLfloat zRotation[16] = {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    };
    
    //设置旋转矩阵
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
}


- (void)dealloc
{
    glDeleteBuffers(1, &_mColorFrameBuffer);
    glDeleteBuffers(1,&_mColorRenderBuffer);
    [self.textMesh releaseBuffer];
    if (_textureId) {
        glDeleteTextures(1, &_textureId);
    }
    if (_mContext) {
        [EAGLContext setCurrentContext:nil];
        _mContext = nil;
    }
}

@end
