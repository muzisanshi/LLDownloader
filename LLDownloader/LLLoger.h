//
//  LLLog.h
//  LLDownloader
//
//  Created by lilei on 16/1/15.
//  Copyright © 2016年 handsight. All rights reserved.
//

#ifndef LLLog_h
#define LLLog_h

@interface LLLoger : NSObject
@property NSString *currentClass;

-(instancetype)initWithClass:(NSString *)className;
-(void)LLLog:(NSString *)msg;
@end

#endif /* LLLog_h */
