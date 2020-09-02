//
//  GLPaintView.h
//  GLPaintDemo
//
//  Created by AceDong on 2020/8/30.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLPaintView : UIView

- (void)erase;

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@end

NS_ASSUME_NONNULL_END
