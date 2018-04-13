//
//  AGLKView.h
//  OpenGLES_2_1Demo
//
//  Created by 广东省深圳市 on 2017/6/10.
//  Copyright © 2017年 Ace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;
@protocol AGLKViewDelegate;

@interface AGLKView : UIView{
    EAGLContext *context;
    GLuint defaultFrameBuffer;
    GLuint colorRenderBuffer;
    GLuint drawableWidth;
    GLuint drawableHeight;
}

@property (nonatomic,weak)IBOutlet id <AGLKViewDelegate> delegate;

@property (nonatomic, retain)EAGLContext *context;
@property (nonatomic, readonly)NSInteger drawableWidth;
@property (nonatomic, readonly)NSInteger drawableHeight;

- (void)display;

@end


#pragma mark - AGLKViewDelegate

@protocol AGLKViewDelegate <NSObject>

@required
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect;

@end
