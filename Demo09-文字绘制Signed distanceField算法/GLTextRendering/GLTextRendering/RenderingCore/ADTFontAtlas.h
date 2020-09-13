//
//  ADTFontAtlas.h
//  GLTextRendering
//
//  Created by AceDong on 2020/9/8.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADTGlyphDescriptor : NSObject <NSSecureCoding>
@property (nonatomic, assign) CGGlyph glyphIndex;
@property (nonatomic, assign) CGPoint topLeftTexCoord;
@property (nonatomic, assign) CGPoint bottomRightTexCoord;
@end

@interface ADTFontAtlas : NSObject <NSSecureCoding>

@property (nonatomic, readonly) UIFont *parentFont;
@property (nonatomic, readonly) CGFloat fontPointSize;
@property (nonatomic, readonly) CGFloat spread;
@property (nonatomic, readonly) size_t textureSize;
@property (nonatomic, readonly) NSArray *glyphDescriptors;
@property (nonatomic, readonly) NSData *textureData;

/// Create a signed-distance field based font atlas with the specified dimensions.
/// The supplied font will be resized to fit all available glyphs in the texture.
- (instancetype)initWithFont:(UIFont *)font textureSize:(size_t)textureSize;

@end

NS_ASSUME_NONNULL_END

