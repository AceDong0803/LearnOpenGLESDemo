//
//  OpenGLMultitextureViewController.m
//  纹理取样循环多重纹理
//
//  Created by AnDong on 2018/5/15.
//  Copyright © 2018年 AnDong. All rights reserved.
//

#import "OpenGLMultitextureViewController.h"

//顶点数据
typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVertex;

//矩形的六个顶点
static const SceneVertex vertices[] = {
    {{1, -1, 0.0f,},{1.0f,0.0f}}, //右下
    {{1, 1,  0.0f},{1.0f,1.0f}}, //右上
    {{-1, 1, 0.0f},{0.0f,1.0f}}, //左上
    
    {{1, -1, 0.0f},{1.0f,0.0f}}, //右下
    {{-1, 1, 0.0f},{0.0f,1.0f}}, //左上
    {{-1, -1, 0.0f},{0.0f,0.0f}}, //左下
};


@interface OpenGLMultitextureViewController (){
    GLuint vertextBufferID;
}

@property (nonatomic,strong)GLKBaseEffect *baseEffect;

@property (nonatomic,strong)GLKTextureInfo *textureInfo1;

@property (nonatomic,strong)GLKTextureInfo *textureInfo2;

@end

@implementation OpenGLMultitextureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //新建OpenGLES 上下文
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc]initWithAPI: kEAGLRenderingAPIOpenGLES2];
    //设置当前上下文
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    //填充VertexArray
    [self fillTexture];
    
    //填充纹理
    [self fillVertexArray];
}

- (void)fillVertexArray{
    glGenBuffers(1, &vertextBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertextBufferID); //绑定指定标识符的缓存为当前缓存
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, positionCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理0
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, textureCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord1); //纹理1
    glVertexAttribPointer(GLKVertexAttribTexCoord1, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, textureCoords));
    
}


- (void)fillTexture{
    //获取图片1
    CGImageRef imageRef1 = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    //通过图片数据产生纹理缓存
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    self.textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:options error:NULL];
    
    //获取图片2
    CGImageRef imageRef2 = [[UIImage imageNamed:@"beetle"] CGImage];
    self.textureInfo2 = [GLKTextureLoader textureWithCGImage:imageRef2 options:options error:NULL];
    
    self.baseEffect.texture2d0.name = self.textureInfo1.name;
    self.baseEffect.texture2d0.target = self.textureInfo1.target;
    
    
    self.baseEffect.texture2d1.name = self.textureInfo2.name;
    self.baseEffect.texture2d1.target = self.textureInfo2.target;
    //设置混合EnvMode
    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    //清除背景色
    glClearColor(0.0f,0.0f,0.0f,1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    if ( 0 != vertextBufferID) {
        glDeleteBuffers(1,
                        &vertextBufferID);
        vertextBufferID = 0;
    }
    [EAGLContext setCurrentContext:nil];
}



@end
