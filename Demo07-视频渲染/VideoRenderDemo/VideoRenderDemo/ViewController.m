//
//  ViewController.m
//  VideoRenderDemo
//
//  Created by AceDong on 2020/9/2.
//  Copyright © 2020 AceDong. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "VideoAGLLayer.h"

@interface ViewController ()
@property (nonatomic , strong) UILabel  *mLabel;
@property (nonatomic , strong) AVAsset *mAsset;
@property (nonatomic , strong) AVAssetReader *mReader;
@property (nonatomic , strong) AVAssetReaderTrackOutput *mReaderVideoTrackOutput;
@property (nonatomic , strong) NSDate *mStartDate;


@property (nonatomic , strong) VideoAGLLayer *mGLView;
@property (nonatomic , strong) CADisplayLink *mDisplayLink;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mGLView = [[VideoAGLLayer alloc]initWithFrame: self.view.frame];
    [self.view.layer addSublayer:self.mGLView];
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
    self.mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    self.mDisplayLink.preferredFramesPerSecond = 30; //默认30的帧率
    [[self mDisplayLink] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[self mDisplayLink] setPaused:YES];
    
    [self loadAsset];
    
}


- (void)loadAsset {
    AVURLAsset *inputAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"abc" ofType:@"mp4"]]];
    __weak typeof(self) weakSelf = self;
    [inputAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler: ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
            if (tracksStatus != AVKeyValueStatusLoaded)
            {
                NSLog(@"error %@", error);
                return;
            }
            weakSelf.mAsset = inputAsset;
            [weakSelf processAsset];
        });
    }];
}


- (AVAssetReader*)createAssetReader
{
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:self.mAsset error:&error];
    
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
    
    [outputSettings setObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    self.mReaderVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[self.mAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] outputSettings:outputSettings];
    self.mReaderVideoTrackOutput.alwaysCopiesSampleData = NO;
    [assetReader addOutput:self.mReaderVideoTrackOutput];
    
    return assetReader;
}

- (void)processAsset
{
    self.mReader = [self createAssetReader];
    
    if ([self.mReader startReading] == NO)
    {
        NSLog(@"Error reading from file at URL: %@", self.mAsset);
        return;
    }
    else {
        self.mStartDate = [NSDate dateWithTimeIntervalSinceNow:0];
        [self.mDisplayLink setPaused:NO];
        NSLog(@"Start reading success.");
    }
}


- (void)displayLinkCallback:(CADisplayLink *)sender
{
    CMSampleBufferRef sampleBuffer = [self.mReaderVideoTrackOutput copyNextSampleBuffer];
        
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer) {
        self.mLabel.text = [NSString stringWithFormat:@"播放%.f秒", [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceDate:self.mStartDate]];
        [self.mLabel sizeToFit];
        self.mGLView.pixelBuffer = pixelBuffer;
        
        if (pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
        }
    }
    else {
        NSLog(@"播放完成");
        [self.mDisplayLink setPaused:YES];
    }
}


@end
