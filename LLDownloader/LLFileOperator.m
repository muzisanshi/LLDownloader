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

-(instancetype)init{
    self.loger = [[LLLoger alloc] initWithClass:[NSString stringWithUTF8String:object_getClassName(self)]];
    return [super init];
}

-(BOOL)isSpaceEnough:(long long)fileLength{
    // 获取documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = paths[0];
    // 获取路径的属性
    NSDictionary *fileSysAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:docDir error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    [self.loger LLLog:[NSString stringWithFormat:@"剩余存储空间大小是:%@",freeSpace]];
    // 判断剩余存储空间是否充足
    if([freeSpace longLongValue] >= fileLength){
        return YES;
    }
    return NO;
}

-(long long)getFileLength:(NSString *)filePath{
    [self.loger LLLog:@"获取文件大小"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    // 获取文件大小（字节）
    long long sizeByte = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    [self.loger LLLog:[NSString stringWithFormat:@"当前文件的大小是：%llu",sizeByte]];
    return sizeByte;
}
@end