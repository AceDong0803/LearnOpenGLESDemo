//
//  ADTMesh.h
//  GLTextRendering
//
//  Created by AceDong on 2020/9/8.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADTMesh : NSObject

@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint indexBuffer;
@property (nonatomic, assign)int indexCount;
@property (nonatomic, assign)int vertexCount;

@end

NS_ASSUME_NONNULL_END
