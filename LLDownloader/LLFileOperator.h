//
//  LLFileOperator.h
//  LLDownloader
//
//  Created by lilei on 16/1/15.
//  Copyright © 2016年 handsight. All rights reserved.
//

#ifndef LLFileOperator_h
#define LLFileOperator_h
#import "LLLoger.h"

@interface LLFileOperator : NSObject
@property LLLoger *loger;

-(BOOL)isSpaceEnough:(long long)fileLength;
-(long long)getFileLength:(NSString *)filePath;
@end

#endif /* LLFileOperator_h */
