//
//  GLKContext.m
//  OpenGLES_2_1Demo
//
//  Created by 广东省深圳市 on 2017/6/12.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext


- (void)setClearColor:(GLKVector4)clearColorRGBA{
    clearColor = clearColorRGBA;
    
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be a current context");
    
    glClearColor(clearColorRGBA.r, clearColorRGBA.g ,clearColorRGBA.b ,clearColorRGBA.a);
}


- (GLKVector4)clearColor{
    return clearColor;
}

- (void)clear:(GLbitfield)mask{
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be a current context");
    glClear(mask);
}

@end
