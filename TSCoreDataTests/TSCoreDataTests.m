//
//  TSCoreDataTests.m
//  TSCoreDataTests
//
//  Created by Tobias Sundstrand on 2014-01-17.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TSAsyncTesting/TSAsyncTesting.h>
#import "TSCoreData.h"
#import "TSInMemoryCoreDataStack.h"

@interface TSCoreData (test)
- (NSManagedObjectContext *)managedObjectContextForThread:(NSThread *)thread;
@end

@interface TSCoreDataTests : XCTestCase

@property(strong) TSCoreData *coreData;

@end

@implementation TSCoreDataTests

- (void)setUp {
    [super setUp];
    [self setupCoreData];
}

- (void)setupCoreData {
    NSError *error = nil;
    TSInMemoryCoreDataStack *stack = [[TSInMemoryCoreDataStack alloc] initWithModelName:@"Test" error:&error];
    XCTAssertNil(error);
    self.coreData = [[TSCoreData alloc] initWithCoreDataStack:stack];
    NSAssert(self.coreData != nil, @"Could not setup core data");
}

- (void)testGettingMainContext {
    NSManagedObjectContext *context = self.coreData.mainManagedObjectContext;
    XCTAssertNotNil(context);
    XCTAssertTrue(context.concurrencyType == NSMainQueueConcurrencyType);
}

- (void)testGettingThreadSpecificContextOnMainThread {

    NSManagedObjectContext *context = self.coreData.threadSpecificContext;
    NSManagedObjectContext *main = self.coreData.mainManagedObjectContext;
    XCTAssertNotNil(context);
    XCTAssertNotNil(main);
    XCTAssertEqual(context, main);
}

- (void)testGettingBackgroundContext {
    NSThread *backgroundThread = [[NSThread alloc] init];
    NSManagedObjectContext *backgroundContext = [self.coreData managedObjectContextForThread:backgroundThread];
    XCTAssertNotNil(backgroundContext);
    XCTAssertNotEqual(backgroundContext, self.coreData.mainManagedObjectContext);
}

- (void)testGettingThreadSpecificContextOnBackgroundThread {

    [TSAsyncTesting testOnBackgroundQueue:^{
        NSManagedObjectContext *context = self.coreData.threadSpecificContext;
        XCTAssertNotNil(context);
        XCTAssertTrue(context.concurrencyType == NSConfinementConcurrencyType);
    }];
}

- (void)testGettingMainContextOnBackgroundThread {
    [TSAsyncTesting testOnBackgroundQueue:^{
        NSManagedObjectContext *context = self.coreData.mainManagedObjectContext;
        XCTAssertNotNil(context);
        XCTAssertTrue(context.concurrencyType == NSMainQueueConcurrencyType);
    }];
}

- (void)testGettingContextFromDifferentThreads {
    __block NSManagedObjectContext *context1 = nil;
    __block NSManagedObjectContext *context2 = nil;

    [TSAsyncTesting testOnBackgroundQueue:^{
        context1 = self.coreData.threadSpecificContext;
        XCTAssertNil(context2);
        XCTAssertNotNil(context1);
    }];

    [TSAsyncTesting testOnBackgroundQueue:^{
        context2 = self.coreData.threadSpecificContext;
        XCTAssertNotNil(context2);
        XCTAssertNotNil(context1);
        XCTAssertNotEqual(context1, context2);
    }];
}

- (void)testGettingContextTwoTimesOnSameThread {

    [TSAsyncTesting testOnBackgroundQueue:^{
        NSManagedObjectContext *originalContext = self.coreData.threadSpecificContext;
        NSManagedObjectContext *secondContext = self.coreData.threadSpecificContext;
        XCTAssertNotNil(originalContext);
        XCTAssertNotNil(secondContext);
        XCTAssertEqual(originalContext, secondContext);
    }];
}

@end
