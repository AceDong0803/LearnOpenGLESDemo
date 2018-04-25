//
//  ViewController.m
//  OpenGLESDemo02-纹理绘图
//
//  Created by AnDong on 2018/4/13.
//  Copyright © 2018年 AnDong. All rights reserved.
//

#import "ViewController.h"


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



@interface ViewController (){
    GLuint vertextBufferID;
}

@property (nonatomic,strong)GLKBaseEffect *baseEffect;

@end

@implementation ViewController

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
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, textureCoords));
    
}


- (void)fillTexture{
    //获取图片
    CGImageRef imageRef = [[UIImage imageNamed:@"Demo.jpg"] CGImage];
    
    //通过图片数据产生纹理缓存
    //GLKTextureInfo封装了纹理缓存的信息，包括是否包含MIP贴图
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:options error:NULL];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
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
