//
//  TSCoreDataTests.m
//  TSCoreDataTests
//
//  Created by Tobias Sundstrand on 2014-01-17.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TSCoreData.h"
#import "TSInMemoryCoreDataStack.h"

@interface TSCoreData (test)

- (NSManagedObjectContext *)contextForThread:(NSThread *)thread;

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
    TSInMemoryCoreDataStack *stack = [[TSInMemoryCoreDataStack alloc] initWithModelName:@"Test"];
    self.coreData = [[TSCoreData alloc] initWithCoreDataStack:stack];
    NSAssert(self.coreData != nil, @"Could not setup core data");
}

- (void)tearDown {
    [self clearCoreData];
    [super tearDown];
}

- (void)clearCoreData {
    [TSCoreData clearSharedInstance];
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

- (void)testThrowsInternalInconsistencyError {
    [self clearCoreData];
    XCTAssertThrowsSpecificNamed([TSCoreData sharedInstance], NSException, NSInternalInconsistencyException);
}

- (void)testGettingBackgroundContext {
    NSThread *backgroundThread = [[NSThread alloc] init];
    NSManagedObjectContext *backgroundContext = [self.coreData contextForThread:backgroundThread];
    XCTAssertNotNil(backgroundContext);
    XCTAssertNotEqual(backgroundContext, self.coreData.mainManagedObjectContext);
}

- (void)testGettingThreadSoecificContextOnBackgroundThread {

}

@end
