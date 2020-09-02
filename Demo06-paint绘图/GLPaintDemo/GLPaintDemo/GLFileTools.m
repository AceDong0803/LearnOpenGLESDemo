//
//  GLFileTools.m
//  GLPaintDemo
//
//  Created by AceDong on 2020/9/2.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "GLFileTools.h"

@implementation GLFileTools


+ (char *)getShaderWithName:(NSString *)name{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType: nil];

    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    return (char *)[content UTF8String];;
    
}

@end
