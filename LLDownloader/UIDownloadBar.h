//
//  UIDownloadBar.h
//  LLDownloader
//
//  Created by lilei on 16/2/1.
//  Copyright © 2016年 handsight. All rights reserved.
//

#ifndef UIDownloadBar_h
#define UIDownloadBar_h

//
//  PublicHeader.h
//  DownloadDemo
//
//  Created by lilei on 16/1/29.
//  Copyright © 2016年 handsight. All rights reserved.
//

#ifndef PublicHeader_h
#define PublicHeader_h
#import <UIKit/UIKit.h>
#import "LLLoger.h"

@interface UIDownloadBar : UIView {
    UIProgressView *progressView;
    NSURLRequest* DownloadRequest;
    NSURLConnection* DownloadConnection;
    NSMutableData* receivedData;

    unsigned long long bytesReceived;
    unsigned long long expectedBytes;
    
    float percentComplete;
    UILabel *lblDownloadBytes;
    UILabel *lblDownloadPercent;
}
@property (nonatomic, readonly) float percentComplete;
@property LLLoger *loger;

-(void)updateView:(unsigned long long) length totalLength:(unsigned long long)total;
@end



#endif /* PublicHeader_h */


#endif /* UIDownloadBar_h */
