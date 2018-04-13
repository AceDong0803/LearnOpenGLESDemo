//
//  OpenGLES_2_3ViewController.h
//  OpenGLES_2_1Demo
//
//  Created by 广东省深圳市 on 2017/6/12.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import <GLKit/GLKit.h>

@class AGLKVertextAttribArrayBuffer;

@interface OpenGLES_2_3ViewController : GLKViewController{
    AGLKVertextAttribArrayBuffer *vertextBuffer;
}

@property (nonatomic,strong)GLKBaseEffect *baseEffect;
@property (nonatomic,strong)AGLKVertextAttribArrayBuffer *vertexBuffer;

@end
