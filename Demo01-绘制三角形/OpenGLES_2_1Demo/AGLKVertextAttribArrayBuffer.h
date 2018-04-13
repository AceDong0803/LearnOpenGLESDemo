//
//  AGLKVertextAttribArrayBuffer.h
//  OpenGLES_2_1Demo
//
//  Created by 广东省深圳市 on 2017/6/12.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface AGLKVertextAttribArrayBuffer : NSObject{
    GLsizeiptr stride;
    GLsizeiptr bufferSizeBytes;
    GLuint glName;
}

@property (nonatomic,readonly)GLuint glName;
@property (nonatomic,readonly)GLsizeiptr bufferSizeBytes;
@property (nonatomic,readonly)GLsizeiptr stride;

- (instancetype)initWithAttribStride:(GLsizeiptr)stride
                    numberofVertices:(GLsizei)count
                                data:(const GLvoid *)dataPtr
                               usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count;

@end
