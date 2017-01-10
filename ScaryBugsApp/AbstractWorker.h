//
//  AbstractWorker.h
//  chat
//
//  Created by ruin on 2015. 3. 14..
//  Copyright (c) 2015년 campmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AbstractWorker : NSObject
{
    dispatch_semaphore_t _sema;
}
@property (nonatomic, strong) NSThread *worker;
@property (nonatomic) BOOL running;
@property (nonatomic, readonly) BOOL finished;

- (void)notify;
- (void)terminate;
- (BOOL)processJob;
- (void)doFinish;
@end
