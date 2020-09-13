//
//  ADTTextMesh.h
//  GLTextRendering
//
//  Created by AceDong on 2020/9/8.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "ADTMesh.h"
#import "ADTFontAtlas.h"


NS_ASSUME_NONNULL_BEGIN

@interface ADTTextMesh : ADTMesh

- (instancetype)initWithString:(NSString *)string
                        inRect:(CGRect)rect
                      withFontAtlas:(ADTFontAtlas *)fontAtlas
                        atSize:(CGFloat)fontSize;

- (void)releaseBuffer;

@end

NS_ASSUME_NONNULL_END
