//
//  ViewController.m
//  GLTextRendering
//
//  Created by Ace on 2020/9/8.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "ViewController.h"
#import "GLSLDemoView.h"

@interface ViewController ()

//@property (nonatomic,strong)ADTRenderLayerView *renderLayerView;

@property (nonatomic,strong)GLSLDemoView *glDemoView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.glDemoView];
}


- (GLSLDemoView *)glDemoView{
    if (!_glDemoView) {
        _glDemoView = [[GLSLDemoView alloc]initWithFrame: self.view.frame];
    }
    return _glDemoView;
}




@end
