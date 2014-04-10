//
//  TSInMemoryCoreDataStackTests.m
//  TSCoreData
//
//  Created by Tobias Sundstrand on 2014-04-03.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TSAsyncTesting/TSAsyncTesting.h>
#import "TSInMemoryCoreDataStack.h"
#import "Chair.h"
#import "NSManagedObject+TSCoreData.h"

@interface TSInMemoryCoreDataStackTests : XCTestCase

@property(strong) TSCoreData *coreData;

@end

@implementation TSInMemoryCoreDataStackTests

- (void)setUp {
    [super setUp];
    id <TSCoreDataStack> stack = [TSInMemoryCoreDataStack coreDataStackWithModelName:@"Test"];
    self.coreData = [TSCoreData coreDataWithCoreDataStack:stack];
    NSError *error = nil;
    [self.coreData clearData:&error];
    XCTAssertNil(error);
}

- (void)testCreatingEntity {
    Chair *chair = [[Chair alloc] initWithManagedObjectContext:self.coreData.threadSpecificContext];
    XCTAssertNotNil(chair);
    XCTAssertNotNil(chair.objectID);
}

- (void)testSettingBasicProperty {
    Chair *chair = [[Chair alloc] initWithManagedObjectContext:self.coreData.threadSpecificContext];
    chair.material = @"Wood";
    XCTAssertEqualObjects(@"Wood", chair.material);
}

- (void)testFetchingWithoutSavingContext {
    [[Chair alloc] initWithManagedObjectContext:self.coreData.threadSpecificContext];
    NSArray *chairs = [self fetchChairs];
    XCTAssertEqual(chairs.count, 1U);
}

- (void)testFetchingInBackgroundWithoutSavingContext {
    [[Chair alloc] initWithManagedObjectContext:self.coreData.threadSpecificContext];
    [TSAsyncTesting testOnBackgroundQueue:^{
        NSArray *chairs = [self fetchChairs];
        XCTAssertEqual(chairs.count, 0U);
    }];
}

- (void)testFetchingOnBackgroundThreadAfterSaving {
    NSManagedObjectContext *context = self.coreData.threadSpecificContext;
    [[Chair alloc] initWithManagedObjectContext:context];
    NSError *error = nil;
    [context save:&error];
    XCTAssertNil(error);
    [TSAsyncTesting testOnBackgroundQueue:^{
        NSArray *chairs = [self fetchChairs];
        XCTAssertEqual(chairs.count, 1U);
    }];
}

- (void)testSavingOnBackgroundThreadAndFetchingOnMain {

    [TSAsyncTesting testOnBackgroundQueue:^{
        NSManagedObjectContext *context = self.coreData.threadSpecificContext;
        [[Chair alloc] initWithManagedObjectContext:context];
        NSError *error = nil;
        [context save:&error];
        XCTAssertNil(error);
    }];

    NSArray *chairs = [self fetchChairs];
    XCTAssertEqual(chairs.count, 1U);
}

- (NSArray *)fetchChairs {
    NSFetchRequest *request = [Chair fetchRequest];
    NSError *error = nil;
    NSArray *objects = [self.coreData.threadSpecificContext executeFetchRequest:request error:&error];
    return objects;
}

@end
