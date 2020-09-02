//
//  ViewController.m
//  GLPaintDemo
//
//  Created by AceDong on 2020/8/30.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "ViewController.h"
#import "GLPaintView.h"


@interface ViewController ()

@property (nonatomic,strong)GLPaintView *paintView;

@property (nonatomic,strong)UISlider *rSlider;
@property (nonatomic,strong)UISlider *gSlider;
@property (nonatomic,strong)UISlider *bSlider;

@property (nonatomic,strong)UIButton *eraseBtn;
@property (nonatomic,strong)UIView *colorView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.paintView = [[GLPaintView alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 120.0f)];
    [self.view addSubview:self.paintView];
    [self.paintView setBrushColorWithRed:0 green:0 blue:0];//默认黑色
    [self initSubView];
}



- (void)initSubView{
    
    UISlider *rSlider = [[UISlider alloc] initWithFrame:CGRectMake(40,self.view.frame.size.height - 120,self.view.frame.size.width-120,40)];
    self.rSlider = rSlider;
    [self.view addSubview:rSlider];
    rSlider.minimumValue = 0.0;
    rSlider.maximumValue = 1.0;
    rSlider.value = 0.0;
    rSlider.thumbTintColor = [UIColor redColor];
    [rSlider addTarget:self action:@selector(valueChange) forControlEvents:UIControlEventValueChanged];
    
    UISlider *gSlider = [[UISlider alloc] initWithFrame:CGRectMake(40,self.view.frame.size.height - 80,self.view.frame.size.width-120,40)];
    self.gSlider = gSlider;
    [self.view addSubview:gSlider];
    gSlider.minimumValue = 0.0;
    gSlider.maximumValue = 1.0;
    gSlider.value = 0.0;
    gSlider.thumbTintColor = [UIColor greenColor];
    [gSlider addTarget:self action:@selector(valueChange) forControlEvents:UIControlEventValueChanged];
    
    
    UISlider *bSlider = [[UISlider alloc] initWithFrame:CGRectMake(40,self.view.frame.size.height - 40,self.view.frame.size.width-120,40)];
    self.bSlider = bSlider;
    [self.view addSubview:bSlider];
    bSlider.minimumValue = 0.0;
    bSlider.maximumValue = 1.0;
    bSlider.value = 0.0;
    bSlider.thumbTintColor = [UIColor blueColor];
    [bSlider addTarget:self action:@selector(valueChange) forControlEvents:UIControlEventValueChanged];
    
    
    
    UIButton *eraseBtn = [[UIButton alloc]initWithFrame: CGRectMake(self.view.frame.size.width - 70,self.view.frame.size.height - 120 , 60, 40)];
    [eraseBtn addTarget:self action:@selector(erase) forControlEvents:UIControlEventTouchUpInside];
    self.eraseBtn = eraseBtn;
    [eraseBtn setBackgroundColor:[UIColor redColor]];
    [eraseBtn setTitle:@"erase" forState:UIControlStateNormal];
    [self.view addSubview:self.eraseBtn];
    
    
    UIView *colorView = [[UIView alloc]initWithFrame: CGRectMake(self.view.frame.size.width - 70,self.view.frame.size.height - 60 , 60, 40)];
    colorView.backgroundColor = [UIColor blackColor];
    self.colorView = colorView;
    [self.view addSubview:self.colorView];
    
}

- (void)valueChange{
    [self.paintView setBrushColorWithRed:self.rSlider.value green:self.gSlider.value blue:self.bSlider.value];
    [self.colorView setBackgroundColor:[UIColor colorWithRed:self.rSlider.value green:self.gSlider.value blue:self.bSlider.value alpha:1.0f]];
}


- (void)erase{
    [self.paintView erase];
}

@end
