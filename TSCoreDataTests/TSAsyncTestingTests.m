//
//  TSAsyncTestingTests.m
//  TSCoreData
//
//  Created by Tobias Sundstrand on 2014-03-06.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TSAsyncTesting.h"

@interface TSAsyncTestingTests : XCTestCase

@end

@implementation TSAsyncTestingTests

- (void)setUp {
    [super setUp];
    [TSAsyncTesting initialize];
}

- (void)tearDown {
    [TSAsyncTesting initialize];
    [super tearDown];
}

- (void)testPerformObBackgroundThread {
    __block BOOL hasRun = NO;
    [TSAsyncTesting testOnBackgroundQueue:^{
        hasRun = YES;
    }];
    XCTAssertTrue(hasRun);
}

- (void)testOnBackgroundThreadTimeOut {
    __block BOOL hasRun = NO;
    XCTAssertThrowsSpecificNamed([TSAsyncTesting testOnBackgroundQueueTimeOut:1 action:^{
        [TSAsyncTesting blockThread];
        hasRun = YES;
    }], NSException, TSTestTimeoutException);

    XCTAssertFalse(hasRun);
}

- (void)testOnOwnQueue {
    __block BOOL hasRun = NO;
    dispatch_queue_t queue = dispatch_queue_create("Test queue", DISPATCH_QUEUE_SERIAL);
    [TSAsyncTesting testWithTimeOut:2 onQueue:queue action:^{
        hasRun = YES;
    }];
    XCTAssertTrue(hasRun);
}

- (void)testBasicWaitAndSignal {
    __block BOOL hasRun = NO;
    dispatch_queue_t queue = dispatch_queue_create("Test queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        hasRun = YES;
        [TSAsyncTesting signal];
    });
    [TSAsyncTesting wait];
    XCTAssertTrue(hasRun);
}

- (void)testBasicTimeout {
    __block BOOL hasRun = NO;
    dispatch_queue_t queue = dispatch_queue_create("Test queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [TSAsyncTesting blockThread];
        hasRun = YES;
        [TSAsyncTesting signal];
    });
    XCTAssertThrowsSpecificNamed([TSAsyncTesting waitWithTimeOut:1], NSException, TSTestTimeoutException);
    XCTAssertFalse(hasRun);
}

- (void)testSignalThrowsInternalInconsistencyErrorIfNoWait {
    XCTAssertThrowsSpecificNamed([TSAsyncTesting signal], NSException, NSInternalInconsistencyException);
}

@end
