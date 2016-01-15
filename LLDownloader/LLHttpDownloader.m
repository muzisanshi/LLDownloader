//
//  LLHttpDownloader.m
//  LLDownloader
//
//  Created by lilei on 16/1/14.
//  Copyright © 2016年 handsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLHttpDownloader.h"

static LLHttpDownloader *instance;
@implementation LLHttpDownloader

+(LLHttpDownloader *)defaultDownloader{
    if(!instance){
        instance = [[LLHttpDownloader alloc] init];
    }
    return instance;
}

-(instancetype)init{
    self.loger = [[LLLoger alloc] initWithClass:[NSString stringWithUTF8String:object_getClassName(self)]];
    BOOL yesBool = YES;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.docDir = paths[0];
    self.rootDir = [NSString stringWithFormat:@"%@/LLDownloader",self.docDir];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.rootDir isDirectory:&yesBool]) {
        [self.loger LLLog:@"创建LLDownloader目录"];
        [[NSFileManager defaultManager] createDirectoryAtPath:self.rootDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [super init];
}
// 从字符串url进行下载资源
-(void)downloadFromUrlString:(NSString *)url withDelegate:(id<DownloaderDelegate>)delegate{
    [self.loger LLLog:@"downloadFromUrlString()"];
    if(url){
        NSURL *nsurl = [NSURL URLWithString:url];
        [self downloadFromUrl:nsurl withDelegate:delegate];
    }else{
        [self.loger LLLog:@"下载地址无效"];
        if(delegate){
            [delegate onDownloadError:@"error"];
        }
    }
}
// 从NSURL进行资源下载
-(void)downloadFromUrl:(NSURL *)url withDelegate:(id<DownloaderDelegate>)delegate{
    [self.loger LLLog:@"downloadFromUrl()"];
    NSString *filePath = nil;
    if(url && [url lastPathComponent]){
        // 创建文件
        filePath = [NSString stringWithFormat:@"%@/%@",self.rootDir,[url lastPathComponent]];
        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            [self.loger LLLog:[NSString stringWithFormat:@"创建了下载文件：%@",filePath]];
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
                [self.loger LLLog:@"下载失败"];
                if(delegate){
                    [delegate onDownloadError:@"error"];
                }
            }else{
                [self.loger LLLog:[NSString stringWithFormat:@"%@",response]];
                [self.loger LLLog:@"下载完成"];
                long long length = [response expectedContentLength];
                [self.loger LLLog:[NSString stringWithFormat:@"下载的文件的大小是：%llu",length]];
                LLFileOperator *operator = [[LLFileOperator alloc] init];
                if ([operator isSpaceEnough:length]) {
                    // 往文件写数据
                    [data writeToFile:filePath atomically:TRUE];
                    [self.loger LLLog:@"写入数据到文件完毕"];
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
        [self.loger LLLog:@"下载地址无效"];
        if(delegate){
            [delegate onDownloadError:@"error"];
        }
    }
}
@end
