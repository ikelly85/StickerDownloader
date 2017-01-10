//
//  ThumbnailWorker.h
//  chat
//
//  Created by kelly on 2015. 10. 22..
//  Copyright © 2015년 campmobile. All rights reserved.
//

#import "AbstractWorker.h"

@interface ThumbnailWorker : AbstractWorker <NSURLSessionDelegate>
{
    NSMutableDictionary *thumbnailUrlMap;
    NSURLSession *session;
}
+ (ThumbnailWorker *)sharedInstance;
@end
