//
//  LLFileOperator.m
//  LLDownloader
//
//  Created by lilei on 16/1/15.
//  Copyright © 2016年 handsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLFileOperator.h"

@implementation LLFileOperator

-(BOOL)isSpaceEnough:(long long)fileLength{
    // 获取documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = paths[0];
    // 获取路径的属性
    NSDictionary *fileSysAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:docDir error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    NSLog(@"剩余存储空间大小是:%@",freeSpace);
    // 判断剩余存储空间是否充足
    if([freeSpace longLongValue] >= fileLength){
        return YES;
    }
    return NO;
}
@end