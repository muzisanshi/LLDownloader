//
//  LLNetworkState.h
//  LLDownloader
//
//  Created by lilei on 16/1/15.
//  Copyright © 2016年 handsight. All rights reserved.
//

#ifndef LLNetworkState_h
#define LLNetworkState_h
#import "LLLoger.h"

@interface LLNetworkState : NSObject
@property LLLoger *loger;
-(BOOL)isNetworkAvailable;
@end

#endif /* LLNetworkState_h */
