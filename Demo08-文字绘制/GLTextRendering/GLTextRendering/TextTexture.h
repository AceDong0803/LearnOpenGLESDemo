////
////  Texture.h
////  GLTextRendering
////
////  Created by Ace on 2020/9/10.
////  Copyright © 2020 AceDong. All rights reserved.
////
//
#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>

@interface TextTexture : NSObject

@property (nonatomic,assign)CGFloat width;
@property (nonatomic,assign)CGFloat height;
@property (nonatomic,assign)GLuint textureId;


@end

