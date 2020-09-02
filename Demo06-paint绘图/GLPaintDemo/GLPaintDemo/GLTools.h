//
//  GLTools.h
//  GLPaintDemo
//
//  Created by AceDong on 2020/8/30.
//  Copyright © 2020 AceDong. All rights reserved.
//

#ifndef GLTools_h
#define GLTools_h


//OpenGL ES常用的shader通用处理C函数封装 参照Apple代码示例

#define glError() { \
    GLenum err = glGetError(); \
    if (err != GL_NO_ERROR) { \
        printf("glError: %04x caught at %s:%u\n", err, __FILE__, __LINE__); \
    } \
}



#import <OpenGLES/ES2/gl.h>

/**
 编译shader
 */
GLint glueCompileShader(GLenum target, GLsizei count, const GLchar **sources, GLuint *shader);

/**
 链接program
 */
GLint glueLinkProgram(GLuint program);

/**
 校验program状态
 */
GLint glueValidateProgram(GLuint program);

/**
 获取glsl中的变量
 */
GLint glueGetUniformLocation(GLuint program, const GLchar *name);

/**
 便捷创建program
 */
GLint glueCreateProgram(const GLchar *vertSource, const GLchar *fragSource,
                    GLsizei attribNameCt, const GLchar **attribNames,
                    const GLint *attribLocations,
                    GLsizei uniformNameCt, const GLchar **uniformNames,
                    GLint *uniformLocations,
                    GLuint *program);

#ifdef __cplusplus
}
#endif

#endif /* GLTools_h */
