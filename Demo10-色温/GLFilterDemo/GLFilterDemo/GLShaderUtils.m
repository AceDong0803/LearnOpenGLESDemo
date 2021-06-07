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

+ (GLuint)loadTexture:(UIImage *)image activeTexture:(GLenum)activeTexture{
    GLuint texture = 0;
    CGImageRef imageRef = image.CGImage;
    if (!image) {
        NSLog(@"load Image texture failed");
        return texture;
    }
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    
    CGContextRef context = CGBitmapContextCreate(imageData,
                                                 width,
                                                 height,
                                                 8,
                                                 4 * width,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM (context, 1.0,-1.0);
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), imageRef);
    CGContextRelease(context);
    glActiveTexture(activeTexture);
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 (GLint)width,
                 (GLint)height,
                 0,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,
                 imageData);
    free(imageData);
    

    return texture;
    
}

@end
