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
    self.networkState = [[LLNetworkState alloc] init];
    
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
-(void)downloadFromUrlString:(NSString *)url withDelegate:(id<DownloaderDelegate>)delegate isResume:(BOOL)flag{
    [self.loger LLLog:@"downloadFromUrlString()"];
    if ([self.networkState isNetworkAvailable]) {
        if(url){
            NSURL *nsurl = [NSURL URLWithString:url];
            [self downloadFromUrl:nsurl withDelegate:delegate isResume:flag];
        }else{
            [self.loger LLLog:@"下载地址无效"];
            if(delegate){
                [delegate onDownloadError:@"downerror"];
            }
        }
    }else{
        [delegate onNetworkUnavailable:@"neterror"];
    }
}
// 从NSURL进行资源下载
-(void)downloadFromUrl:(NSURL *)url withDelegate:(id<DownloaderDelegate>)delegate isResume:(BOOL)flag{
    [self.loger LLLog:@"downloadFromUrl()"];
    NSString *filePath = nil;
    if ([self.networkState isNetworkAvailable]) {
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
                
                LLFileOperator *operator = [[LLFileOperator alloc] init];
                NSURLResponse *response = nil;
                NSError *error = nil;
                
                // 判断是否是断点下载
                if (flag) {
                    [self.loger LLLog:@"当前进行断点下载"];
                    // 定义请求(默认是GET方法)
                    NSMutableURLRequest *mutRequest = [NSMutableURLRequest requestWithURL:url];
                    //获取当前文件的大小
                    long long fileSize = [operator getFileLength:filePath];
                    [mutRequest setValue:[NSString stringWithFormat:@"bytes=%llu-",fileSize] forHTTPHeaderField:@"Range"];
                    [mutRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
                    NSData *data1 = [NSURLConnection sendSynchronousRequest:mutRequest returningResponse:&response error:&error];
                    
                    if (error) {
                        [self.loger LLLog:@"断点下载失败"];
                        if(delegate){
                            [delegate onDownloadError:@"downerror"];
                        }

                    }else{
                        
                        [self.loger LLLog:@"断点下载文件结束"];
                        long long length1 = [response expectedContentLength];
                        [self.loger LLLog:[NSString stringWithFormat:@"断点下载的大小是：%llu",length1]];
                        // 把数据写到文件
                        if ([operator isSpaceEnough:length1]) {
                            // 往文件写数据
//                            [data1 writeToFile:filePath atomically:TRUE];
                            FILE *file = fopen([filePath UTF8String], [@"ab+" UTF8String]);
                            if(file != NULL){
                                fseek(file, 0, SEEK_END);
                            }
                            unsigned long readSize = [data1 length];
                            fwrite((const void *)[data1 bytes], readSize, 1, file);
                            fclose(file);
                            
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
                    
                }else{
                    [self.loger LLLog:@"当前不进行断点下载"];
                    // 定义请求(默认是GET方法)
                    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
                    NSData *data2 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                    if(error){
                        [self.loger LLLog:@"下载失败"];
                        if(delegate){
                            [delegate onDownloadError:@"downerror"];
                        }
                    }else{
                        [self.loger LLLog:[NSString stringWithFormat:@"%@",response]];
                        [self.loger LLLog:@"下载完成"];
                        long long length2 = [response expectedContentLength];
                        [self.loger LLLog:[NSString stringWithFormat:@"下载的文件的大小是：%llu",length2]];
            
                        if ([operator isSpaceEnough:length2]) {
                            // 往文件写数据
                            [data2 writeToFile:filePath atomically:TRUE];
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
                }
            });
            
        }else{
            [self.loger LLLog:@"下载地址无效"];
            if(delegate){
                [delegate onDownloadError:@"downerror"];
            }
        }
    }else{
        if(delegate){
            [delegate onNetworkUnavailable:@"neterror"];
        }
    }
}
@end
