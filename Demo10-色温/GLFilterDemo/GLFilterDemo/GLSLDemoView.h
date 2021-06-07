//
//  GLSLDemoView.h
//  GLSLDemo
//
//  Created by AceDong on 2020/8/28.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLSLDemoView : UIView

@property (nonatomic, assign) CGFloat temperature;
@property (nonatomic, assign) CGFloat saturation;

- (void)layoutGLViewWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
