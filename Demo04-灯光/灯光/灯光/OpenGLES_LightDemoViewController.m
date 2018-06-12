//
//  OpenGLES_LightDemoVC.m
//  灯光
//
//  Created by AnDong on 2018/6/5.
//  Copyright © 2018年 AnDong. All rights reserved.
//

#import "OpenGLES_LightDemoViewController.h"

typedef struct {
    GLKVector3  position; //顶点
    GLKVector3  normal; //法线
}
SceneVertex;

typedef struct {
    SceneVertex vertices[3];
}
SceneTriangle;

//9个数据顶点
static const SceneVertex vertexA =
{{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexB =
{{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexC =
{{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexD =
{{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexE =
{{ 0.0,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexF =
{{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexG =
{{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexH =
{{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexI =
{{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

//8 triangles
#define NUM_FACES (8)

//法线顶点
#define NUM_NORMAL_LINE_VERTS (48)

//法线顶点+两个灯光方向顶点
#define NUM_LINE_VERTS (NUM_NORMAL_LINE_VERTS + 2)

//函数前置声明
static SceneTriangle SceneTriangleMake(
                                       const SceneVertex vertexA,
                                       const SceneVertex vertexB,
                                       const SceneVertex vertexC);

static GLKVector3 SceneTriangleFaceNormal(
                                          const SceneTriangle triangle);

static void SceneTrianglesUpdateFaceNormals(
                                            SceneTriangle someTriangles[NUM_FACES]);

static void SceneTrianglesUpdateVertexNormals(
                                              SceneTriangle someTriangles[NUM_FACES]);

static  void SceneTrianglesNormalLinesUpdate(
                                             const SceneTriangle someTriangles[NUM_FACES],
                                             GLKVector3 lightPosition,
                                             GLKVector3 someNormalLineVertices[NUM_LINE_VERTS]);

static  GLKVector3 SceneVector3UnitNormal(
                                          const GLKVector3 vectorA,
                                          const GLKVector3 vectorB);

@interface OpenGLES_LightDemoViewController (){
    
    //8个三角形
    SceneTriangle triangles[NUM_FACES];
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKBaseEffect *extraEffect;

//顶点buffer
@property (nonatomic,assign)  GLuint vertexBufferID;

//用于绘制法线方向的buffer
@property (nonatomic,assign)  GLuint extraBufferID;

@property (nonatomic) GLfloat centerVertexHeight;
@property (nonatomic) BOOL shouldUseFaceNormals;
@property (nonatomic) BOOL shouldDrawNormals;



@end

@implementation OpenGLES_LightDemoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.context = [[EAGLContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    
    //设置灯光漫反射颜色
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         0.7f, // Red
                                                         0.7f, // Green
                                                         0.7f, // Blue
                                                         1.0f);// Alpha
    //灯光位置
    self.baseEffect.light0.position = GLKVector4Make(
                                                     1.0f,
                                                     1.0f,
                                                     0.5f,
                                                     0.0f);
    
    
    //设置绘制法线的baseEffect
    self.extraEffect = [[GLKBaseEffect alloc] init];
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor = GLKVector4Make(
                                                    0.0f, // Red
                                                    1.0f, // Green
                                                    0.0f, // Blue
                                                    1.0f);// Alpha
    
    {
        //这里是视点变换，暂时不做解释，用于下一章在讲解
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(
                                                            GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
        modelViewMatrix = GLKMatrix4Rotate(
                                           modelViewMatrix,
                                           GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
        modelViewMatrix = GLKMatrix4Translate(
                                              modelViewMatrix,
                                              0.0f, 0.0f, 0.25f);
        
        self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
        self.extraEffect.transform.modelviewMatrix = modelViewMatrix;
    }
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    //使用顶点初始化八个三角形数据
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    //Bind vertexBuffer
    glGenBuffers(1, &_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(triangles), triangles, GL_DYNAMIC_DRAW);
    
    
    //Bind 法线绘制的Buffer 默认是不绘制的
    glGenBuffers(1, &_extraBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, _extraBufferID);
    glBufferData(GL_ARRAY_BUFFER, 0, NULL, GL_DYNAMIC_DRAW);
    
    
    
    //默认展示效果
    self.centerVertexHeight = 0.0f;
    self.shouldUseFaceNormals = YES;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    [self.baseEffect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    //位置缓存
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, position));
    
    //法线缓存
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, normal));
    
    
    //绘制
    glDrawArrays(GL_TRIANGLES, 0, sizeof(triangles) / sizeof(SceneVertex));
    
    if(self.shouldDrawNormals)
    {
        [self drawNormals];
    }
    
}

#pragma makr - Event Handle

- (IBAction)shouldUseFaceNormal:(UISwitch *)sender {
    self.shouldUseFaceNormals = sender.isOn;
}

- (IBAction)shouldDrawNormals:(UISwitch *)sender {
    self.shouldDrawNormals = sender.isOn;
}
- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender {
    
    self.centerVertexHeight = sender.value;
}


//设置中心点高度
- (void)setCenterVertexHeight:(GLfloat)aValue
{
    _centerVertexHeight = aValue;
    
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = self.centerVertexHeight;
    
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
    [self updateNormals];
}

//刷新法向量模式
- (void)setShouldUseFaceNormals:(BOOL)aValue
{
    if(aValue != _shouldUseFaceNormals)
    {
        _shouldUseFaceNormals = aValue;
        
        [self updateNormals];
    }
}


//绘制法线
- (void)drawNormals
{
    GLKVector3  normalLineVertices[NUM_LINE_VERTS];
    
    //更新48个法向量顶点和两个灯光方向顶点
    SceneTrianglesNormalLinesUpdate(triangles,
                                    GLKVector3MakeWithArray(self.baseEffect.light0.position.v),
                                    normalLineVertices);
    
    glBindBuffer(GL_ARRAY_BUFFER, _extraBufferID);
    glBufferData(GL_ARRAY_BUFFER, NUM_LINE_VERTS * sizeof(GLKVector3), normalLineVertices, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLKVector3), NULL);
    
    
    //绘制每条顶点法线
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor =
    GLKVector4Make(0.0, 1.0, 0.0, 1.0); // Green
    
    [self.extraEffect prepareToDraw];
    glDrawArrays(GL_LINES, 0, NUM_NORMAL_LINE_VERTS);
    
    
    //绘制灯光方向
    self.extraEffect.constantColor =
    GLKVector4Make(1.0, 1.0, 0.0, 1.0); // Yellow
    
    [self.extraEffect prepareToDraw];
    glDrawArrays(GL_LINES, NUM_NORMAL_LINE_VERTS, NUM_LINE_VERTS);
}

//更新法向量
- (void)updateNormals
{
    if(self.shouldUseFaceNormals)
    {
        // Lighting Step 3 使用平均法线
        SceneTrianglesUpdateFaceNormals(triangles);
    }
    else
    {
        // Lighting Step 3 使用顶点法线
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    
    //重新绑定缓存
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(triangles), triangles, GL_DYNAMIC_DRAW);
}

//计算8个三角形的法向量，并且赋值更新
static void SceneTrianglesUpdateFaceNormals(
                                            SceneTriangle someTriangles[NUM_FACES])
{
    int                i;
    
    for (i=0; i<NUM_FACES; i++)
    {
        GLKVector3 faceNormal = SceneTriangleFaceNormal(
                                                        someTriangles[i]);
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}

//更新三角形法向量 顶点采用平均法向量
static void SceneTrianglesUpdateVertexNormals(
                                              SceneTriangle someTriangles[NUM_FACES])
{
    SceneVertex newVertexA = vertexA;
    SceneVertex newVertexB = vertexB;
    SceneVertex newVertexC = vertexC;
    SceneVertex newVertexD = vertexD;
    SceneVertex newVertexE = someTriangles[3].vertices[0];
    SceneVertex newVertexF = vertexF;
    SceneVertex newVertexG = vertexG;
    SceneVertex newVertexH = vertexH;
    SceneVertex newVertexI = vertexI;
    GLKVector3 faceNormals[NUM_FACES];
    
    // Calculate the face normal of each triangle
    for (int i=0; i<NUM_FACES; i++)
    {
        faceNormals[i] = SceneTriangleFaceNormal(
                                                 someTriangles[i]);
    }
    
    //每个顶点的平均法向量
    newVertexA.normal = faceNormals[0];
    newVertexB.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[1]),
                                                                             faceNormals[2]),
                                                               faceNormals[3]), 0.25);
    newVertexC.normal = faceNormals[1];
    newVertexD.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[2]),
                                                                             faceNormals[4]),
                                                               faceNormals[6]), 0.25);
    newVertexE.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[2],
                                                                                           faceNormals[3]),
                                                                             faceNormals[4]),
                                                               faceNormals[5]), 0.25);
    newVertexF.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[1],
                                                                                           faceNormals[3]),
                                                                             faceNormals[5]),
                                                               faceNormals[7]), 0.25);
    newVertexG.normal = faceNormals[6];
    newVertexH.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[4],
                                                                                           faceNormals[5]),
                                                                             faceNormals[6]),
                                                               faceNormals[7]), 0.25);
    newVertexI.normal = faceNormals[7];
    
    //更新triangles
    someTriangles[0] = SceneTriangleMake(
                                         newVertexA,
                                         newVertexB,
                                         newVertexD);
    someTriangles[1] = SceneTriangleMake(
                                         newVertexB,
                                         newVertexC,
                                         newVertexF);
    someTriangles[2] = SceneTriangleMake(
                                         newVertexD,
                                         newVertexB,
                                         newVertexE);
    someTriangles[3] = SceneTriangleMake(
                                         newVertexE,
                                         newVertexB,
                                         newVertexF);
    someTriangles[4] = SceneTriangleMake(
                                         newVertexD,
                                         newVertexE,
                                         newVertexH);
    someTriangles[5] = SceneTriangleMake(
                                         newVertexE,
                                         newVertexF,
                                         newVertexH);
    someTriangles[6] = SceneTriangleMake(
                                         newVertexG,
                                         newVertexD,
                                         newVertexH);
    someTriangles[7] = SceneTriangleMake(
                                         newVertexH,
                                         newVertexF,
                                         newVertexI);
}

//更新三角形法线 还有灯光方向线
static  void SceneTrianglesNormalLinesUpdate(
                                             const SceneTriangle someTriangles[NUM_FACES],
                                             GLKVector3 lightPosition,
                                             GLKVector3 someNormalLineVertices[NUM_LINE_VERTS])
{
    int                       trianglesIndex;
    int                       lineVetexIndex = 0;
    
    // 每条法向量的顶点确定，用于绘制法线
    for (trianglesIndex = 0; trianglesIndex < NUM_FACES;
         trianglesIndex++)
    {
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[0].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[0].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[0].normal,
                                               0.5));
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[1].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[1].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[1].normal,
                                               0.5));
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[2].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[2].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[2].normal,
                                               0.5));
    }
    
    // 添加法线顶点
    someNormalLineVertices[lineVetexIndex++] =
    lightPosition;
    
    someNormalLineVertices[lineVetexIndex] = GLKVector3Make(
                                                            0.0,
                                                            0.0,
                                                            -0.5);
}

//生成triangle
static SceneTriangle SceneTriangleMake(
                                       const SceneVertex vertexA,
                                       const SceneVertex vertexB,
                                       const SceneVertex vertexC)
{
    SceneTriangle   result;
    
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    
    return result;
}

//triangle的法向量
static GLKVector3 SceneTriangleFaceNormal(
                                          const SceneTriangle triangle)
{
    GLKVector3 vectorA = GLKVector3Subtract(
                                            triangle.vertices[1].position,
                                            triangle.vertices[0].position);
    GLKVector3 vectorB = GLKVector3Subtract(
                                            triangle.vertices[2].position,
                                            triangle.vertices[0].position);
    
    return SceneVector3UnitNormal(
                                  vectorA,
                                  vectorB);
}

//法向量
GLKVector3 SceneVector3UnitNormal(
                                  const GLKVector3 vectorA,
                                  const GLKVector3 vectorB)
{
    return GLKVector3Normalize(
                               GLKVector3CrossProduct(vectorA, vectorB));
}

@end

