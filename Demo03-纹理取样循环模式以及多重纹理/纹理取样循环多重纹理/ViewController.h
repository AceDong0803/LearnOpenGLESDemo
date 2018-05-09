//
//  ViewController.h
//  纹理取样循环多重纹理
//
//  Created by AnDong on 2018/5/9.
//  Copyright © 2018年 AnDong. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController

@property (nonatomic,assign)BOOL shouldUseLineFilter;
@property (nonatomic,assign)BOOL shouldAnimate;
@property (nonatomic,assign)BOOL shouldRepeatTexture;
@property (nonatomic,assign)GLfloat sCoordinateOffset;

@end

