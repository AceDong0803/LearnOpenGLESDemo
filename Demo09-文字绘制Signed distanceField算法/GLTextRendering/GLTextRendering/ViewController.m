//
//  ViewController.m
//  GLTextRendering
//
//  Created by AceDong on 2020/9/8.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "ViewController.h"
#import "ADTRenderLayerView.h"

@interface ViewController ()

@property (nonatomic,strong)ADTRenderLayerView *renderLayerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    ADTRenderLayerView *TextRenderView = [[ADTRenderLayerView alloc]initWithFrame: self.view.frame];
    [self.view addSubview:TextRenderView];
    
}




@end
