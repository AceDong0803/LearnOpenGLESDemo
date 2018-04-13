//
//  OpenGLES_2_3ViewController.m
//  OpenGLES_2_1Demo
//
//  Created by 广东省深圳市 on 2017/6/12.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import "OpenGLES_2_3ViewController.h"
#import "AGLKVertextAttribArrayBuffer.h"
#import "AGLKContext.h"

@interface OpenGLES_2_3ViewController ()

@end

@implementation OpenGLES_2_3ViewController


@synthesize baseEffect;
@synthesize vertexBuffer;


typedef struct {
    GLKVector3  positionCoords;
}
SceneVertex;

/////////////////////////////////////////////////////////////////
// Define vertex data for a triangle to use in example
static const SceneVertex vertices[] =
{
    {{-0.5f, -0.5f, 0.0}}, // lower left corner
    {{ 0.5f, -0.5f, 0.0}}, // lower right corner
    {{-0.5f,  0.5f, 0.0}}  // upper left corner
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"ViewController's view is not a GLKView");
    
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(
                                                              0.0f, // Red
                                                              0.0f, // Green
                                                              0.0f, // Blue 
                                                              1.0f);// Alpha
    self.vertexBuffer = [[AGLKVertextAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberofVertices:sizeof(vertices)/sizeof(SceneVertex) data:vertices usage:GL_STATIC_DRAW];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:3];

}



- (void)dealloc{
    // Make the view's context current
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    // Delete buffers that aren't needed when view is unloaded
    self.vertexBuffer = nil;
    
    // Stop using the context created in -viewDidLoad
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];


}

@end
