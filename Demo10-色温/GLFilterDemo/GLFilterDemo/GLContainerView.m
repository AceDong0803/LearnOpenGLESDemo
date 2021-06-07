//
//  GLSLDemoView.m
//  GLSLDemo
//
//  Created by AceDong on 2020/8/28.
//  Copyright © 2020 AceDong. All rights reserved.
//


#import "GLContainerView.h"
#import <AVFoundation/AVFoundation.h>
#import "GLSLDemoView.h"

@interface GLContainerView()

@property (nonatomic, strong) GLSLDemoView *glView;

@end

@implementation GLContainerView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupGLView];
    }
    return self;
}

#pragma mark - Setup
- (void)setupGLView {
    self.glView = [[GLSLDemoView alloc] initWithFrame:self.bounds];
    [self addSubview:self.glView];
}

#pragma mark - Private
- (void)layoutGlkView {
    CGSize imageSize = self.image.size;
    CGRect frame = AVMakeRectWithAspectRatioInsideRect(imageSize, self.bounds);
    self.glView.frame = frame;
    self.glView.contentScaleFactor = imageSize.width / frame.size.width;
}

#pragma mark - Public
- (void)setImage:(UIImage *)image {
    _image = image;
    [self layoutGlkView];
    [self.glView layoutGLViewWithImage:_image];
}

- (void)setColorTempValue:(CGFloat)colorTempValue {
    _colorTempValue = colorTempValue;
    self.glView.temperature = colorTempValue;
}

- (void)setSaturationValue:(CGFloat)saturationValue {
    _saturationValue = saturationValue;
    self.glView.saturation = saturationValue;
}


@end
