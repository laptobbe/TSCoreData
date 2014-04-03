//
// Created by Tobias Sundstrand on 2014-03-05.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "TSAsyncTesting.h"

NSString *const TSTestTimeoutException = @"TSTestTimoutException";

static NSUInteger threadCount = 0;
static dispatch_semaphore_t semaphore = nil;
#define SUFFICIENT_LONG_WAIT (60 * 60 * 24)

@implementation TSAsyncTesting

+ (void)testOnBackgroundQueue:(dispatch_block_t)block {
    [self testOnBackgroundQueueTimeOut:SUFFICIENT_LONG_WAIT action:block];
}

+ (void)testOnBackgroundQueueTimeOut:(NSTimeInterval)time action:(dispatch_block_t)block {
    dispatch_queue_t backgroundQueue = dispatch_queue_create("Test background thread", DISPATCH_QUEUE_SERIAL);
    [self testWithTimeOut:time onQueue:backgroundQueue action:block];
}

+ (void)testWithTimeOut:(NSTimeInterval)time onQueue:(dispatch_queue_t)queue action:(dispatch_block_t)action {

    dispatch_async(queue, ^{
        [[NSThread currentThread] setName:[NSString stringWithFormat:@"TSAsyncTesting thread %d", ++threadCount]];
        action();
        [self signal];
    });
    [self waitWithTimeOut:time];
}

+ (void)wait {
    [self waitWithTimeOut:SUFFICIENT_LONG_WAIT];
}

+ (void)initialize {
    semaphore = nil;
}

+ (void)signal {
    if (!semaphore) {
        [NSException raise:NSInternalInconsistencyException format:@"No waiting action"];
    }
    dispatch_semaphore_signal(semaphore);
}

+ (void)waitWithTimeOut:(NSTimeInterval)timeOut {
    semaphore = dispatch_semaphore_create(0);
    long result = dispatch_semaphore_wait(semaphore, [self dispatchTimeFromTimeInterval:timeOut]);
    semaphore = nil;
    if (result != 0) {
        [NSException raise:TSTestTimeoutException format:@"Timed out waiting"];
    }
}

+ (dispatch_time_t)dispatchTimeFromTimeInterval:(NSTimeInterval)timeInterval {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t) (timeInterval * NSEC_PER_SEC));
}

+ (void)blockThread {
    for(;;);
}


@end