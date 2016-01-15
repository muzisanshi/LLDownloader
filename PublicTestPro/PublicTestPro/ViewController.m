//
//  ViewController.m
//  PublicTestPro
//
//  Created by lilei on 16/1/14.
//  Copyright © 2016年 handsight. All rights reserved.
//

#import "ViewController.h"
#import "LLDownloader.h"

@interface ViewController () <DownloaderDelegate>
- (IBAction)test:(id)sender;

@end

@implementation ViewController

-(void)showAlert:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)test:(id)sender {
//    HttpDownloader *downloader = [[HttpDownloader alloc] init];
    NSString *url = @"http://download.handsight.cn/tvhelper.apk";
    LLHttpDownloader *downloader = [LLHttpDownloader defaultDownloader];
    [downloader downloadFromUrlString:url withDelegate:self];
}

-(void)onDownloadError:(NSString *)msg{
    NSLog(@"%@",msg);
    [self performSelectorOnMainThread:@selector(showAlert:) withObject:msg waitUntilDone:YES];
}
-(void)onDownloadOver:(NSString *)msg{
    NSLog(@"%@",msg);
    [self performSelectorOnMainThread:@selector(showAlert:) withObject:msg waitUntilDone:YES];
}
-(void)onSpaceNotEnough:(NSString *)msg{
    NSLog(@"%@",msg);
    [self performSelectorOnMainThread:@selector(showAlert:) withObject:msg waitUntilDone:YES];
}
-(void)onNetworkUnavailable:(NSString *)msg{
    NSLog(@"%@",msg);
    [self performSelectorOnMainThread:@selector(showAlert:) withObject:msg waitUntilDone:YES];
}
@end
