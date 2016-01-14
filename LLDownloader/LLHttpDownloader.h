//
//  LLHttpDownloader.h
//  LLDownloader
//
//  Created by lilei on 16/1/14.
//  Copyright © 2016年 handsight. All rights reserved.
//

#ifndef LLHttpDownloader_h
#define LLHttpDownloader_h

@protocol DownloaderDelegate <NSObject>
-(void)onDownloadOver:(NSString *)msg;
-(void)onDownloadError:(NSString *)msg;
@end

@interface LLHttpDownloader : NSObject

@property NSString *LOG_TAG;
@property NSString *rootDir;
@property NSString *docDir;

// 获取单例
+(LLHttpDownloader *)defaultDownloader;
// 从字符串url进行下载资源
-(void)downloadFromUrlString:(NSString *)url withDelegate:(id<DownloaderDelegate>)delegate;
// 从NSURL进行资源下载
-(void)downloadFromUrl:(NSURL *)url withDelegate:(id<DownloaderDelegate>)delegate;
@end

#endif /* LLHttpDownloader_h */
