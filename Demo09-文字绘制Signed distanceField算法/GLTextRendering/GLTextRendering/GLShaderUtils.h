//
//  GLShaderUtils.h
//  GLSLDemo
//
//  Created by AceDong on 2020/8/28.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>


#define glError() { \
    GLenum err = glGetError(); \
    if (err != GL_NO_ERROR) { \
        printf("glError: %04x caught at %s:%u\n", err, __FILE__, __LINE__); \
    } \
}

NS_ASSUME_NONNULL_BEGIN

@interface GLShaderUtils : NSObject

/**
 加载shader
 @param vshFilePath 顶点着色器shader 路径
 @param fshFilePath 片源着色器shader 路径
 @return GLuint
 */
+ (GLuint)loadShaders:(NSString *)vshFilePath
                  fsh:(NSString *)fshFilePath;



+ (BOOL)linkProgram:(GLuint)program;


+ (void)loadTexture:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
