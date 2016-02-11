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
    self.totalLenth = length;
    [self.loger LLLog:[NSString stringWithFormat:@"断点下载的大小是：%llu",length]];
    
    if ([self.fileOperator isSpaceEnough:length]) {
        if (!self.file) {
            self.file = fopen([self.filePath UTF8String], [@"ab+" UTF8String]);
        }
    }else{
        // 退出下载
        if (self.connection) {
            [self.connection cancel];
            [self.loger LLLog:@"下载已经退出"];
            [self.delegate onSpaceNotEnough:@"nenough"];
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
    unsigned long long readSize = [data length];
    fwrite((const void *)[data bytes], readSize, 1, self.file);
    
    // 回调更新UIDownloadBar的函数
    if (self.bar) {
        // 不阻塞主线程的方式更新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.bar updateView:readSize totalLength:self.totalLenth];
            [self.loger LLLog:@"更新了界面"];
        });
    }
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

//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
//    NSLog(@"调用了willSendRequest函数");
//    return request;
//}
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//    NSLog(@"调用了didReceiveResponse函数");
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    NSLog(@"调用了didReceiveData函数");
//}
//
//- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request{
//    NSLog(@"调用了needNewBodyStream函数");
//    return nil;
//}
//- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
// totalBytesWritten:(NSInteger)totalBytesWritten
//totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
//    NSLog(@"调用了didSendBodyData函数");
//
//}
//
//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
//    NSLog(@"调用了willCacheResponse函数");
//    return cachedResponse;
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    NSLog(@"调用了connectionDidFinishLoading函数");
//
//}

//- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes{
//    
//    NSLog(@"调用了didWriteData函数");
//}
//- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes{
//    NSLog(@"调用了connectionDidResumeDownloading函数");
//}
//
//- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL{
//    NSLog(@"调用了connectionDidFinishDownloading函数");
//}


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

-(instancetype)initWithBar:(LLDownloadBar *) bar{
    self.bar = bar;
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
    if ([self.networkState isNetworkAvailable]) {
        if(url && [url lastPathComponent]){
            // 创建文件
            self.filePath = [NSString stringWithFormat:@"%@/%@",self.rootDir,[url lastPathComponent]];
            if(![[NSFileManager defaultManager] fileExistsAtPath:self.filePath]){
                [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
                [self.loger LLLog:[NSString stringWithFormat:@"创建了下载文件：%@",self.filePath]];
            }
<<<<<<< Updated upstream
            
            self.fileOperator = [[LLFileOperator alloc] init];
            
            // 判断是否是断点下载
            if (flag) {
                [self.loger LLLog:@"当前进行断点下载"];
                // 定义请求(默认是GET方法)
                NSMutableURLRequest *mutRequest = [NSMutableURLRequest requestWithURL:url];
                    
                //获取当前文件的大小
                long long fileSize = [self.fileOperator getFileLength:self.filePath];
                [mutRequest setHTTPMethod:@"GET"];
                [mutRequest setValue:[NSString stringWithFormat:@"bytes=%llu-",fileSize] forHTTPHeaderField:@"Range"];
                [mutRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
                // 下面这行代码本来就是异步操作
                self.connection = [[NSURLConnection alloc] initWithRequest:mutRequest delegate:self];
=======
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
//                    NSMutableURLRequest *mutRequest = [NSMutableURLRequest requestWithURL:url];
//                    //获取当前文件的大小
//                    long long fileSize = [operator getFileLength:filePath];
//                    [mutRequest setHTTPMethod:@"GET"];
//                    [mutRequest setTimeoutInterval:5];
//                    [mutRequest setValue:[NSString stringWithFormat:@"bytes=%llu-",fileSize] forHTTPHeaderField:@"Range"];
//                    [mutRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
                    NSURLRequest *mutRequest = [NSURLRequest requestWithURL:url];
                    self.connection = [[NSURLConnection alloc] initWithRequest:mutRequest delegate:self];
                    [self.connection start];

//                    NSData *data1 = [NSURLConnection sendSynchronousRequest:mutRequest returningResponse:&response error:&error];
//                    
//                    if (error) {
//                        [self.loger LLLog:@"断点下载失败"];
//                        if(delegate){
//                            [delegate onDownloadError:@"downerror"];
//                        }
//
//                    }else{
//                        
//                        [self.loger LLLog:@"断点下载文件结束"];
//                        long long length1 = [response expectedContentLength];
//                        [self.loger LLLog:[NSString stringWithFormat:@"断点下载的大小是：%llu",length1]];
//                        // 把数据写到文件
//                        if ([operator isSpaceEnough:length1]) {
//                            FILE *file = fopen([filePath UTF8String], [@"ab+" UTF8String]);
//                            if(file != NULL){
//                                [self.loger LLLog:@"打开文件成功"];
//                                if(fseek(file, 0, SEEK_END) == 0){
//                                    [self.loger LLLog:@"重置文件指针成功"];
//                                }else{
//                                    [self.loger LLLog:@"重置文件指针失败"];
//                                }
//                            }
//                            unsigned long readSize = [data1 length];
//                            fwrite((const void *)[data1 bytes], readSize, 1, file);
//                            fclose(file);
//                            
//                            NSLog(@"下载后文件的大小是：%llu",[operator getFileLength:filePath]);
//                            [self.loger LLLog:@"写入数据到文件完毕"];
//                            if(delegate){
//                                [delegate onDownloadOver:filePath];
//                            }
//                        }else{
//                            if(delegate){
//                                [delegate onSpaceNotEnough:@"nenough"];
//                            }
//                        }
//                    }
>>>>>>> Stashed changes
                    
            }else{
                [self.loger LLLog:@"当前不进行断点下载"];
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
                            [delegate onDownloadError:@"downerror"];
                        }
                    }else{
                        [self.loger LLLog:[NSString stringWithFormat:@"%@",response]];
                        [self.loger LLLog:@"下载完成"];
                        long long length = [response expectedContentLength];
                        [self.loger LLLog:[NSString stringWithFormat:@"下载的文件的大小是：%llu",length]];
            
                        if ([self.fileOperator isSpaceEnough:length]) {
                            // 往文件写数据
                            [data writeToFile:self.filePath atomically:TRUE];
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
                });// 异步任务结束
            }
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
