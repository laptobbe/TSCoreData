//
// Created by Tobias Sundstrand on 2014-03-05.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const TSTestTimeoutException;

@interface TSAsyncTesting : NSObject

+ (void)testOnBackgroundQueue:(dispatch_block_t)block;

+ (void)testOnBackgroundQueueTimeOut:(NSTimeInterval)time1 action:(dispatch_block_t)block;

+ (void)testWithTimeOut:(NSTimeInterval)time onQueue:(dispatch_queue_t)queue action:(dispatch_block_t)action;

+ (void)signal;

+ (void)wait;

+ (void)waitWithTimeOut:(NSTimeInterval)timeOut;

+ (void)blockThread;
@end