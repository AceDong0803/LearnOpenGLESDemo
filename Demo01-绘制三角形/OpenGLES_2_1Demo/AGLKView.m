//
//  AGLKView.m
//  OpenGLES_2_1Demo
//
//  Created by 广东省深圳市 on 2017/6/10.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AGLKView

@synthesize delegate;
@synthesize context;


- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)aContext{
    if (self = [super initWithFrame:frame]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.drawableProperties =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:NO],
         kEAGLDrawablePropertyRetainedBacking,
         kEAGLColorFormatRGBA8,
         kEAGLDrawablePropertyColorFormat
         ,nil];
        self.context = aContext;
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.drawableProperties =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:NO],
         kEAGLDrawablePropertyRetainedBacking,  //这个是指不需要保存以前绘制的图像留作备用
         kEAGLColorFormatRGBA8,                 //表示使用8位RGB保存层内的颜色
         kEAGLDrawablePropertyColorFormat
         ,nil];
    }
    return self;
}

//告知coreAnimation层创建CAEAGLLayer层
+ (Class)layerClass{
    return [CAEAGLLayer class];
}


- (void)setContext:(EAGLContext *)aContext{
    if (context != aContext) {
        [EAGLContext setCurrentContext:context];
        
        if (0 != defaultFrameBuffer) {
            glDeleteFramebuffers(1, &defaultFrameBuffer);
            defaultFrameBuffer = 0;
        }
        
        if (0 != colorRenderBuffer) {
            glDeleteRenderbuffers(1, &colorRenderBuffer);
            colorRenderBuffer = 0;
        }
        
        context = aContext;
        
        if (nil != context) {
            context = aContext;
            [EAGLContext setCurrentContext:context];
            
            glGenFramebuffers(1, &defaultFrameBuffer);
            glBindBuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
            
            glGenRenderbuffers(1, &colorRenderBuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
            
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
        }
    }
}

- (EAGLContext *)context{
    return context;
}

- (void)display{
    [EAGLContext setCurrentContext:self.context];
    glViewport(0, 0, (int)self.drawableWidth,(int)self.drawableHeight);
    [self drawRect:[self bounds]];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)drawRect:(CGRect)rect{
    if (self.delegate) {
        [self.delegate glkView:self drawInRect:rect];
    }
}



- (void)layoutSubviews{
    CAEAGLLayer *eagLayer = (CAEAGLLayer *)self.layer;
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eagLayer];
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete frame buffer object %x",status);
    }

}

- (NSInteger)drawableWidth{
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_WIDTH,
                                 &backingWidth);
    return (NSInteger)backingWidth;
}


- (NSInteger)drawableHeight{
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_HEIGHT,
                                 &backingHeight);
    return (NSInteger)backingHeight;
}


- (void)dealloc{
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    context = nil;
}

@end
