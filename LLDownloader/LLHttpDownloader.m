//
//  LLHttpDownloader.m
//  LLDownloader
//
//  Created by lilei on 16/1/14.
//  Copyright © 2016年 handsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLHttpDownloader.h"

//static LLHttpDownloader *instance;
@implementation LLHttpDownloader

//+(LLHttpDownloader *)defaultDownloader{
//    if(!instance){
//        instance = [[LLHttpDownloader alloc] init];
//    }
//    return [[LLHttpDownloader alloc] init];
//}

// 实现NSURLConnectionDataDelegate的函数
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [self.loger LLLog:@"收到了HTTP响应报文"];
    long long length = [response expectedContentLength];
    [self.loger LLLog:[NSString stringWithFormat:@"断点下载的大小是：%llu",length]];
    if (!self.fileOperator) {
        self.fileOperator = [[LLFileOperator alloc] init];
    }
    
    if ([self.fileOperator isSpaceEnough:length]) {
        if (!self.file) {
            self.file = fopen([self.filePath UTF8String], [@"ab+" UTF8String]);
        }
    }else{
        // 退出下载
        if (self.connection) {
            [self.connection cancel];
            [self.loger LLLog:@"下载已经退出"];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.loger LLLog:[NSString stringWithFormat:@"收到了数据，长度是：%lu",[data length]]];
    if(self.file){
        [self.loger LLLog:@"打开文件成功"];
        if(fseek(self.file, 0, SEEK_END) == 0){
            [self.loger LLLog:@"重置文件指针成功"];
        }else{
            [self.loger LLLog:@"重置文件指针失败"];
        }
    }
    unsigned long readSize = [data length];
    fwrite((const void *)[data bytes], readSize, 1, self.file);
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.loger LLLog:@"HTTP连接出错"];
    if (self.file) {
        fclose(self.file);
    }
    [self.delegate onDownloadError:@"downerror"];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self.loger LLLog:@"HTTP数据加载完毕"];
    if (self.file) {
        fclose(self.file);
    }
    [self.delegate onDownloadOver:self.filePath];
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
    self.delegate = delegate;
//    NSString *filePath = nil;
    if ([self.networkState isNetworkAvailable]) {
        if(url && [url lastPathComponent]){
            // 创建文件
            self.filePath = [NSString stringWithFormat:@"%@/%@",self.rootDir,[url lastPathComponent]];
            if(![[NSFileManager defaultManager] fileExistsAtPath:self.filePath]){
                [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
                [self.loger LLLog:[NSString stringWithFormat:@"创建了下载文件：%@",self.filePath]];
            }
            // 使用同步任务队列，异步任务下载
//            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
//            dispatch_async(globalQueue, ^{
            
                LLFileOperator *operator = [[LLFileOperator alloc] init];
                NSURLResponse *response = nil;
                NSError *error = nil;
                
                // 判断是否是断点下载
                if (flag) {
                    [self.loger LLLog:@"当前进行断点下载"];
                    // 定义请求(默认是GET方法)
                    NSMutableURLRequest *mutRequest = [NSMutableURLRequest requestWithURL:url];
                    
                    //获取当前文件的大小
                    long long fileSize = [operator getFileLength:self.filePath];
                    [mutRequest setHTTPMethod:@"GET"];
                    [mutRequest setValue:[NSString stringWithFormat:@"bytes=%llu-",fileSize] forHTTPHeaderField:@"Range"];
                    [mutRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
                    // 下面这行代码本来就是异步操作
                    self.connection = [[NSURLConnection alloc] initWithRequest:mutRequest delegate:self];
                    
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
                            [data2 writeToFile:self.filePath atomically:TRUE];
                            [self.loger LLLog:@"写入数据到文件完毕"];
                            if(delegate){
                                [delegate onDownloadOver:self.filePath];
                            }
                        }else{
                            if(delegate){
                                [delegate onSpaceNotEnough:@"nenough"];
                            }
                        }
                    }
                }
//            });
            
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
