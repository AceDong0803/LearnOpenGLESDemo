//
//  AppDelegate.m
//  VideoRenderDemo
//
//  Created by AceDong on 2020/9/2.
//  Copyright © 2020 AceDong. All rights reserved.
//

//@import QuartzCore;
#include <QuartzCore/QuartzCore.h>
#include <CoreVideo/CoreVideo.h>

@interface VideoAGLLayer : CAEAGLLayer
@property CVPixelBufferRef pixelBuffer;
- (id)initWithFrame:(CGRect)frame;
- (void)resetRenderBuffer;
@end
