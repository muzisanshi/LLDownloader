//
//  LLHttpDownloader.m
//  LLDownloader
//
//  Created by lilei on 16/1/14.
//  Copyright © 2016年 handsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLHttpDownloader.h"
#import "LLFileOperator.h"

static LLHttpDownloader *instance;
@implementation LLHttpDownloader

+(LLHttpDownloader *)defaultDownloader{
    if(!instance){
        instance = [[LLHttpDownloader alloc] init];
    }
    return instance;
}

-(instancetype)init{
    BOOL yesBool = YES;
    self.LOG_TAG = @"HttpDownloader-----";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.docDir = paths[0];
    self.rootDir = [NSString stringWithFormat:@"%@/LLDownloader",self.docDir];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.rootDir isDirectory:&yesBool]) {
        NSLog(@"%@创建LLDownloader目录",self.LOG_TAG);
        [[NSFileManager defaultManager] createDirectoryAtPath:self.rootDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [super init];
}
// 从字符串url进行下载资源
-(void)downloadFromUrlString:(NSString *)url withDelegate:(id<DownloaderDelegate>)delegate{
    NSLog(@"%@downloadFromUrlString()",self.LOG_TAG);
    if(url){
        NSURL *nsurl = [NSURL URLWithString:url];
        [self downloadFromUrl:nsurl withDelegate:delegate];
    }else{
        NSLog(@"%@下载地址无效",self.LOG_TAG);
        if(delegate){
            [delegate onDownloadError:@"error"];
        }
    }
}
// 从NSURL进行资源下载
-(void)downloadFromUrl:(NSURL *)url withDelegate:(id<DownloaderDelegate>)delegate{
    NSLog(@"%@downloadFromUrl()",self.LOG_TAG);
    NSString *filePath = nil;
    if(url && [url lastPathComponent]){
        // 创建文件
        filePath = [NSString stringWithFormat:@"%@/%@",self.rootDir,[url lastPathComponent]];
        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            NSLog(@"%@创建了下载文件：%@",self.LOG_TAG,filePath);
        }
        // 使用同步任务队列，异步任务下载
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        dispatch_async(globalQueue, ^{
            // 定义请求(默认是GET方法)
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            NSURLResponse *response = nil;
            NSError *error = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if(error){
                NSLog(@"%@下载失败",self.LOG_TAG);
                if(delegate){
                    [delegate onDownloadError:@"error"];
                }
            }else{
                NSLog(@"%@%@",self.LOG_TAG,response);
                NSLog(@"%@下载完成",self.LOG_TAG);
                long long length = [response expectedContentLength];
                NSLog(@"%@要下载的文件的大小是：%llu",self.LOG_TAG,length);
                LLFileOperator *operator = [[LLFileOperator alloc] init];
                if ([operator isSpaceEnough:length]) {
                    // 往文件写数据
                    [data writeToFile:filePath atomically:TRUE];
                    NSLog(@"%@写入数据到文件完毕",self.LOG_TAG);
                    if(delegate){
                        [delegate onDownloadOver:filePath];
                    }
                }else{
                    if(delegate){
                        [delegate onSpaceNotEnough:@"nenough"];
                    }
                }
            }
        });
        
    }else{
        NSLog(@"%@下载地址无效",self.LOG_TAG);
        if(delegate){
            [delegate onDownloadError:@"error"];
        }
    }
}
@end
