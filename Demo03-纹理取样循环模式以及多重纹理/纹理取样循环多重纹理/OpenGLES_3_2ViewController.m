//
//  OpenGLES_3_2ViewController.m
//  OpenGLES_3_2Demo
//
//  Created by 广东省深圳市 on 2017/6/13.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import "OpenGLES_3_2ViewController.h"


@interface GLKEffectPropertyTexture (AGLKAdditions)
- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;

@end

@implementation GLKEffectPropertyTexture(AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID value:(GLint)value{
    glBindTexture(self.target, self.name);
    glTexParameteri(self.target, parameterID, value);
}

@end

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoord;
}SceneVertex;

//顶点
static SceneVertex vertices[] =
{
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}}, // lower left corner
    {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}}, // lower right corner
    {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}}, // upper left corner
};

//默认顶点
static const SceneVertex defaultVertices[] =
{
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
    {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
    {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}},
};


//move结构体
static GLKVector3 movementVectors[3] = {
    {-0.02f,  -0.01f, 0.0f},
    {0.01f,  -0.005f, 0.0f},
    {-0.01f,   0.01f, 0.0f},
};


@interface OpenGLES_3_2ViewController(){
     GLuint vertextBufferID;
}


@property (nonatomic,strong)GLKBaseEffect *baseEffect;



@property (nonatomic,assign)BOOL shouldUseLineFilter;
@property (nonatomic,assign)BOOL shouldAnimate;
@property (nonatomic,assign)BOOL shouldRepeatTexture;
@property (nonatomic,assign)GLfloat sCoordinateOffset;
@end

@implementation OpenGLES_3_2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredFramesPerSecond = 60;
    self.shouldAnimate = YES;
    self.shouldRepeatTexture = YES;
    self.shouldUseLineFilter = NO;
    
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's is not a GLKView");
    
    view.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    //顶点缓存和纹理
    [self loadVertexBuffer];
    [self loadTexture];
}


- (void)loadVertexBuffer{
    glGenBuffers(1, &vertextBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertextBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
}


- (void)loadTexture{
    //绑定图片纹理
    CGImageRef imageRef = [[UIImage imageNamed:@"grid.png"] CGImage];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
}


- (void)updateTextureParameters{
    
    glBindTexture(self.baseEffect.texture2d0.target, self.baseEffect.texture2d0.name);
    glTexParameterf(self.baseEffect.texture2d0.target, GL_TEXTURE_WRAP_S, (self.shouldRepeatTexture) ? GL_REPEAT : GL_CLAMP_TO_EDGE);
    glTexParameterf(self.baseEffect.texture2d0.target, GL_TEXTURE_MAG_FILTER, (self.shouldUseLineFilter) ? GL_LINEAR : GL_NEAREST);
    
    
//    //Category设置和上面代码一致
//    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_S value:(self.shouldRepeatTexture) ? GL_REPEAT : GL_CLAMP_TO_EDGE];
}

- (void)updateAnimateVertexPositions{
    if (_shouldAnimate) {
        
        int i;
        
        for (i = 0; i < 3; i++) {
            vertices[i].positionCoords.x += movementVectors[i].x;
            if (vertices[i].positionCoords.x > 1.0f ||
                vertices[i].positionCoords.x < -1.0f) {
                movementVectors[i].x = -movementVectors[i].x;
            }
            
            vertices[i].positionCoords.y += movementVectors[i].y;
            if(vertices[i].positionCoords.y >= 1.0f ||
               vertices[i].positionCoords.y <= -1.0f)
            {
                movementVectors[i].y = -movementVectors[i].y;
            }
            vertices[i].positionCoords.z += movementVectors[i].z;
            if(vertices[i].positionCoords.z >= 1.0f ||
               vertices[i].positionCoords.z <= -1.0f)
            {
                movementVectors[i].z = -movementVectors[i].z;
            }
        }
        
        
        
    }
    else{
        
        int i;
        for(i = 0; i < 3; i++)
        {
            vertices[i].positionCoords.x =
            defaultVertices[i].positionCoords.x;
            vertices[i].positionCoords.y =
            defaultVertices[i].positionCoords.y;
            vertices[i].positionCoords.z =
            defaultVertices[i].positionCoords.z;
        }
    
    }
    
    {  // Adjust the S texture coordinates to slide texture and
        // reveal effect of texture repeat vs. clamp behavior
        int    i;  // 'i' is current vertex index
        
        for(i = 0; i < 3; i++)
        {
            vertices[i].textureCoord.s =
            (defaultVertices[i].textureCoord.s +
             _sCoordinateOffset);
        }
    }
}


- (void)update{
    
    //更新动画顶点位置
    [self updateAnimateVertexPositions];

    //更新纹理参数设置
    [self updateTextureParameters];

    //刷新vertexBuffer
    glBindBuffer(GL_ARRAY_BUFFER, vertextBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT);
    [self.baseEffect prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, vertextBufferID);

    //设置vertex偏移指针
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex),NULL + offsetof(SceneVertex, positionCoords));
    
    
    //设置textureCoords偏移指针
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex),NULL + offsetof(SceneVertex, textureCoord));
    
    //Draw
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (IBAction)takeShouldAnimateFrom:(UISwitch *)sender {
    self.shouldAnimate = [sender isOn];
}
- (IBAction)takeSCoordinateOffsetFrom:(UISlider *)sender {
    self.sCoordinateOffset = [sender value];
}
- (IBAction)takeShouldRepeatTextureFrom:(UISwitch *)sender {
    self.shouldRepeatTexture = [sender isOn];
}
- (IBAction)takeShouldUseLinearFilterFrom:(UISwitch *)sender {
    self.shouldUseLineFilter = [sender isOn];
}

@end
