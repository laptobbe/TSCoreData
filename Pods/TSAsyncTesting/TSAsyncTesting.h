//
// Created by Tobias Sundstrand on 2014-03-05.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^TSAsyncWhenBlock)();

typedef void (^TSAsyncActionBlock)();

extern NSString *const TSTestTimeoutException;

@interface TSAsyncTesting : NSObject

+ (void)testOnBackgroundQueue:(TSAsyncActionBlock)action;

+ (void)testOnBackgroundQueueTimeOut:(NSTimeInterval)time1 action:(TSAsyncActionBlock)action;

+ (void)testOnBackgroundQueueTimeOut:(NSTimeInterval)time action:(TSAsyncActionBlock)action signalWhen:(TSAsyncWhenBlock)when;

+ (void)testWithTimeOut:(NSTimeInterval)time onQueue:(dispatch_queue_t)queue action:(TSAsyncActionBlock)action signalWhen:(TSAsyncWhenBlock)when;

+ (void)signal;

+ (void)wait;

+ (void)waitWithTimeOut:(NSTimeInterval)timeOut;

+ (void)blockThread;

+ (void)signalWhen:(TSAsyncWhenBlock)when;


@end