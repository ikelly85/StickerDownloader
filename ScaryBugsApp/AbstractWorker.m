//
//  AbstractWorker.m
//  chat
//
//  Created by ruin on 2015. 3. 14..
//  Copyright (c) 2015년 campmobile. All rights reserved.
//

#import "AbstractWorker.h"

@implementation AbstractWorker

- (instancetype)init
{
    self = [super init];

    _sema = dispatch_semaphore_create(0);
    _worker = [[NSThread alloc]initWithTarget:self selector:@selector(doWork) object:nil];
    [_worker setThreadPriority:0.1];
    _finished = NO;
    _running = NO;
    return self;
}

#pragma mark - thread work
- (void)doWork
{
    while (TRUE) {  //기본적으로 무한 루프
        if (_finished) {
            [self doFinish];
            break;
        }

        _running = YES;
        //-------------------------
        // 작업
        @autoreleasepool {
            NSLog(@"do worker !");
            BOOL remain = [self processJob]; //남아있다면
            if (remain) {     //남아있다면 한번더
                continue;
            }
        }
        //-------------------------


        //만약에 아이템이 하나도 없다면 세마포머 카운트 업
        _running = NO;
        dispatch_semaphore_wait(_sema, DISPATCH_TIME_FOREVER);



        //아니라면 컨티뉴
    }
}

- (void)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self)
        {
            if (_worker && [_worker isExecuting]) {               // 실행중이 아님
                dispatch_semaphore_signal(_sema);               // 세마포어를 놓아준다.
            } else {
                _worker = [[NSThread alloc]initWithTarget:self selector:@selector(doWork) object:nil];
                [_worker setThreadPriority:0.1];
                _finished = NO;
                
                [_worker start];
            }
        }
    });
}

- (void)terminate
{
    _finished = YES;
    dispatch_semaphore_signal(_sema); // 세마포어를 놓아준다.
    [_worker cancel];
    _worker = nil;
}

- (BOOL)processJob
{
    NSLog(@"abstract worker running!!! need override -(BOOL) processJob; method");
    // do nothing!
    return NO;
}

- (void)doFinish
{
    _finished = NO; //초기 상태로 만듬
    _running = NO;
    dispatch_semaphore_signal(_sema); // 세마포어를 놓아준다.
/*
    [_worker cancel];
    _worker = [[NSThread alloc]initWithTarget:self selector:@selector(doWork) object:nil];
    [_worker setThreadPriority:0.1];
 */
}

@end
