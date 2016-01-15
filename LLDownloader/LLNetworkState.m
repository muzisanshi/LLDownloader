//
//  LLNetworkState.m
//  LLDownloader
//
//  Created by lilei on 16/1/15.
//  Copyright © 2016年 handsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "LLNetworkState.h"

@implementation LLNetworkState

-(instancetype)init{
    self.loger = [[LLLoger alloc] initWithClass:[NSString stringWithUTF8String:object_getClassName(self)]];
    return [super init];
}

-(BOOL)isNetworkAvailable{
    BOOL state = FALSE;
    // 测试网络的地址
    NSString *url = @"www.baidu.com";
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [url UTF8String]);
    state = SCNetworkReachabilityGetFlags(ref, &flags);
    CFRelease(ref);
    
    if(state){
        // kSCNetworkReachabilityFlagsReachable：能够连接网络
        // kSCNetworkReachabilityFlagsConnectionRequired：能够连接网络，但是首先得建立连接过程
        // kSCNetworkReachabilityFlagsIsWWAN：判断是否通过蜂窝网覆盖的连接，比如EDGE，GPRS或者目前的3G.主要是区别通过WiFi的连接。
        BOOL flagsReachable = ((flags & kSCNetworkFlagsReachable) != 0);
        BOOL connectionRequired = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
        BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
        state = ((flagsReachable && !connectionRequired) || nonWiFi) ? YES : NO;
        
        if(state){
            [self.loger LLLog:@"网络连接正常"];
        }else{
            [self.loger LLLog:@"网络连接不可用"];
        }
    }
    
    return state;
}

@end