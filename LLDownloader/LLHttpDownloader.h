//
//  LLHttpDownloader.h
//  LLDownloader
//
//  Created by lilei on 16/1/14.
//  Copyright © 2016年 handsight. All rights reserved.
//

#ifndef LLHttpDownloader_h
#define LLHttpDownloader_h

#import "LLFileOperator.h"
#import "LLLoger.h"
#import "LLNetworkState.h"

@protocol DownloaderDelegate <NSObject>
// 网络不可用，msg是neterror
-(void)onNetworkUnavailable:(NSString *)msg;
// 下载成功，msg是下载到本地的文件的绝对路径
-(void)onDownloadOver:(NSString *)msg;
// 下载失败，msg是downerror
-(void)onDownloadError:(NSString *)msg;
// 下载失败，msg是nenough
-(void)onSpaceNotEnough:(NSString *)msg;
@end

@interface LLHttpDownloader : NSObject <NSURLConnectionDataDelegate>

@property NSURLConnection *connection;
@property LLLoger *loger;
@property LLNetworkState *networkState;
@property NSString *rootDir;
@property NSString *docDir;
@property NSString *filePath;
@property id<DownloaderDelegate> delegate;
@property LLFileOperator *fileOperator;
@property FILE *file;

// 获取单例
//+(LLHttpDownloader *)defaultDownloader;
// 从字符串url进行下载资源
-(void)downloadFromUrlString:(NSString *)url withDelegate:(id<DownloaderDelegate>)delegate isResume:(BOOL)flag;
// 从NSURL进行资源下载
-(void)downloadFromUrl:(NSURL *)url withDelegate:(id<DownloaderDelegate>)delegate isResume:(BOOL)flag;
@end

#endif /* LLHttpDownloader_h */
