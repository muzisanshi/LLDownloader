//
//  UIDownloadBar.m
//  LLDownloader
//
//  Created by lilei on 16/2/1.
//  Copyright © 2016年 handsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIDownloadBar.h"
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@implementation UIDownloadBar
@synthesize percentComplete;

- (UIDownloadBar *)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.loger = [[LLLoger alloc] initWithClass:[NSString stringWithUTF8String:object_getClassName(self)]];
    if(self) {
        self.layer.borderWidth = 2.0;
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.backgroundColor = [UIColor grayColor];
        //进度条，中间
        progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        progressView.frame = CGRectMake(10, 20, self.frame.size.width-20, 20);
        [self addSubview:progressView];
        //左下角
        CGRect lblDownloadBytesFrame = CGRectMake(10, frame.size.height-35, 120, 20);
        lblDownloadBytes = [[UILabel alloc]initWithFrame:lblDownloadBytesFrame];
        lblDownloadBytes.textColor = [UIColor whiteColor];
        lblDownloadBytes.backgroundColor = [UIColor clearColor];
        [self addSubview:lblDownloadBytes];
        //右下角
        CGRect lblDownloadPercentFrame = CGRectMake(frame.size.width-50
                                                    , frame.size.height-35, 60, 20);
        lblDownloadPercent = [[UILabel alloc]initWithFrame:lblDownloadPercentFrame];
        lblDownloadPercent.textColor = [UIColor whiteColor];
        lblDownloadPercent.backgroundColor = [UIColor clearColor];
        [self addSubview:lblDownloadPercent];
        
        
        lblDownloadPercent.text = @"0%";
        bytesReceived = percentComplete = 0;
        receivedData = [[NSMutableData alloc] initWithLength:0];
        progressView.progress = 0.0;
        progressView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)updateView:(unsigned long long) length totalLength:(unsigned long long)total{
    [self.loger LLLog:@"调用了updateView函数"];
    bytesReceived = (bytesReceived + length);
    lblDownloadBytes.text = [NSString stringWithFormat:@"%.02f/%.02fMB",
                                 (float)bytesReceived/1048576,(float)total/1048576];
    //百分比
    lblDownloadPercent.text = [NSString stringWithFormat:@"%.0f%%",
                                   (((float)bytesReceived/1048576)/((float)total/1048576))*100];
    if(expectedBytes != NSURLResponseUnknownLength) {
        progressView.progress = ((bytesReceived/(float)total)*100)/100;
        percentComplete = progressView.progress*100;
    }
}
@end