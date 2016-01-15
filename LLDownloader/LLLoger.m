//
//  LLLog.m
//  LLDownloader
//
//  Created by lilei on 16/1/15.
//  Copyright © 2016年 handsight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLLoger.h"

@implementation LLLoger
-(instancetype)initWithClass:(NSString *)className{
    self.currentClass = className;
    return [super init];
}
-(void)LLLog:(NSString *)msg{
    NSLog(@"%@-----%@",self.currentClass,msg);
}
@end