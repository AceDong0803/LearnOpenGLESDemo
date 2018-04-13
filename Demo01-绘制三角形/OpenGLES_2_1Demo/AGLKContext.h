//
//  GLKContext.h
//  OpenGLES_2_1Demo
//
//  Created by 广东省深圳市 on 2017/6/12.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface AGLKContext : EAGLContext{
    GLKVector4 clearColor;
}

@property (nonatomic, assign)GLKVector4 clearColor;

- (void)clear:(GLbitfield)mask;

@end
