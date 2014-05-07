//
//  TSBinaryCoreDataStackTests.m
//  TSCoreData
//
//  Created by Tobias Sundstrand on 2014-04-11.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TSAsyncTesting/TSAsyncTesting.h>
#import "TSCoreDataStackTestCase.h"
#import "TSBinaryCoreDataStack.h"
#import "Chair.h"
#import "NSManagedObject+TSCoreData.h"
#import "Table.h"

@interface TSBinaryCoreDataStackTests : TSCoreDataStackTestCase

@end

@implementation TSBinaryCoreDataStackTests

- (void)setUp {
    [super setUp];
    [self setupCoreData];
    [self clearCoreData];
    [self cleanRegisteredObjects];
    [self verifyRegisteredObjects];
}

- (void)tearDown {
    [self cleanRegisteredObjects];
    [self verifyRegisteredObjects];
    [super tearDown];
}

- (void)setupCoreData {
    [super deleteCoreDataFileForModel:@"Test"];
    [super setupCoreDataWithStackClass:[TSBinaryCoreDataStack class] modelName:@"Test"];
}

- (void)testClearingBinaryStore {
    Chair *chair = [[Chair alloc] initWithManagedObjectContext:self.coreData.threadSpecificContext];
    chair.material = @"Wood";
    chair.height = @1.23;

    Table *table = [[Table alloc] initWithManagedObjectContext:self.coreData.threadSpecificContext];
    [table addChairsObject:chair];
    table.material = @"Metal";

    NSError *error = nil;
    [self.coreData.threadSpecificContext save:&error];
    XCTAssertNil(error);

    NSArray *chairs = [self fetchChairs];
    NSArray *tables = [self fetchTables];
    XCTAssertEqual(chairs.count, 1U);
    XCTAssertEqual(tables.count, 1U);

    [self.coreData clearData:&error];
    XCTAssertNil(error);

    chairs = [self fetchChairs];
    tables = [self fetchTables];
    XCTAssertEqual(chairs.count, 0U);
    XCTAssertEqual(tables.count, 0U);
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
    [[Chair alloc] initWithManagedObjectContext:self.coreData.mainManagedObjectContext];
    [TSAsyncTesting testOnBackgroundQueue:^{
        NSArray *chairs = [self fetchChairs];
        XCTAssertEqual(chairs.count, 0U);
    }];
}

- (void)testFetchingOnBackgroundThreadAfterSaving {
    NSManagedObjectContext *context = self.coreData.mainManagedObjectContext;
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
@end
