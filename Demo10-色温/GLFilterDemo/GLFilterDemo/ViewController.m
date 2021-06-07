//
//  ViewController.m
//  GLSLDemo
//
//  Created by AceDong on 2020/8/28.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "ViewController.h"
#import "GLContainerView.h"

@interface ViewController ()

@property (nonatomic,strong)GLContainerView *glDemoView;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    
    [self.glDemoView setImage:[UIImage imageNamed:@"Demo"]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.glDemoView];
    
    
    UISlider *slider = [[UISlider alloc]initWithFrame: CGRectMake(20, self.view.frame.size.height - 100, 300, 30)];
    slider.value = 0.5;
    [slider addTarget:self action:@selector(saturationSliderChange:) forControlEvents:UIControlEventValueChanged];
    slider.maximumValue = 2;
    [self.view addSubview:slider];
    
    
    UISlider *slider1 = [[UISlider alloc]initWithFrame: CGRectMake(20, self.view.frame.size.height - 50, 300, 30)];
    slider1.value = 0.5;
    [slider1 addTarget:self action:@selector(temperatureSliderChange:) forControlEvents:UIControlEventValueChanged];
    slider1.maximumValue = 1;
    slider1.minimumValue = -1;
    [self.view addSubview:slider1];

}

- (void)saturationSliderChange:(UISlider *)slider{
    [self.glDemoView setSaturationValue:slider.value];
}

- (void)temperatureSliderChange:(UISlider *)slider{
    [self.glDemoView setColorTempValue:slider.value];
}


- (GLContainerView *)glDemoView{
    if (!_glDemoView) {
        _glDemoView = [[GLContainerView alloc]initWithFrame: self.view.frame];
    }
    return _glDemoView;
}

@end
