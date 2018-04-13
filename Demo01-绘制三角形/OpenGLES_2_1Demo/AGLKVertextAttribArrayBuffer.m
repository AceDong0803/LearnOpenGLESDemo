//
//  AGLKVertextAttribArrayBuffer.m
//  OpenGLES_2_1Demo
//
//  Created by 广东省深圳市 on 2017/6/12.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import "AGLKVertextAttribArrayBuffer.h"


@interface AGLKVertextAttribArrayBuffer ()

@property (nonatomic,assign)GLsizeiptr bufferSizeBytes;
@property (nonatomic,assign)GLsizeiptr stride;

@end

@implementation AGLKVertextAttribArrayBuffer

@synthesize glName;
@synthesize bufferSizeBytes;
@synthesize stride;


- (instancetype)initWithAttribStride:(GLsizeiptr)aStride numberofVertices:(GLsizei)count data:(const GLvoid *)dataPtr usage:(GLenum)usage{
    NSParameterAssert(0 < aStride);
    NSParameterAssert(0 < count);
    NSParameterAssert(NULL != dataPtr);
    
    if (nil != (self = [super init])) {
        stride = aStride;
        bufferSizeBytes = stride *count;
        glGenBuffers(1, &glName);
        glBindBuffer(GL_ARRAY_BUFFER, self.glName);
        glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes,dataPtr,usage);
        NSAssert(0 != self.glName, @"Failed to generate GLName");
    }
    return self;
}

- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable{
    glBindBuffer(GL_ARRAY_BUFFER, self.glName);
    if (shouldEnable) {
        glEnableVertexAttribArray(index);
    }
    
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, (GLsizei)self.stride, NULL + offset);
}


- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count{
    NSAssert(self.bufferSizeBytes >= (first + count) * self.stride, @"Attemp to draw more vertex Data than available");
    glDrawArrays(mode, first, count);
}


- (void)dealloc{
    if (0 != glName) {
        glDeleteBuffers(1, &glName);
        glName = 0;
    }
}

@end
