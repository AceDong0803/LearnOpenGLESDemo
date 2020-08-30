//
//  GLShaderUtils.m
//  GLSLDemo
//
//  Created by AceDong on 2020/8/28.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "GLShaderUtils.h"
#import <UIKit/UIKit.h>

@implementation GLShaderUtils


+ (BOOL)linkProgram:(GLuint)program{
    
    glLinkProgram(program);
    GLint linkRet;
    glGetProgramiv(program, GL_LINK_STATUS, &linkRet);
    
    if (linkRet == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        return NO;
    }
    else{
        return YES;
    }
    
}

+ (GLuint)loadShaders:(NSString *)vshFilePath
                  fsh:(NSString *)fshFilePath{
    
    GLuint vShader,fShader;
    GLint program = glCreateProgram();
    
    //编译
    [self compileShader:&vShader type:GL_VERTEX_SHADER file:vshFilePath];
    [self compileShader:&fShader type:GL_FRAGMENT_SHADER file:fshFilePath];
    
    glAttachShader(program, vShader);
    glAttachShader(program, fShader);
    
    glDeleteShader(vShader);
    glDeleteShader(fShader);

    return program;
}


+ (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    
    if (error) {
        NSLog(@"加载shader 本地file失败");
        return;
    }
    
    const GLchar *source = (GLchar *)[content UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

}

+ (void)loadTexture:(NSString *)imageName{
    
    CGImageRef image = [UIImage imageNamed:imageName].CGImage;
    if (!image) {
        NSLog(@"load Image texture failed");
        return;
    }
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    GLubyte * imageData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef imageContext = CGBitmapContextCreate(imageData, width, height, 8, width*4,
                                                      CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), image);
    CGContextRelease(imageContext);
    glBindTexture(GL_TEXTURE_2D, 0);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    glBindTexture(GL_TEXTURE_2D, 0);
    free(imageData);
    
}

@end
