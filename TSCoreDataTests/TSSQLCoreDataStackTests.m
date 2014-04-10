//
//  TSSQLCoreDataStackTests.m
//  TSCoreData
//
//  Created by Tobias Sundstrand on 2014-04-08.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TSAsyncTesting/TSAsyncTesting.h>
#import "TSCoreData.h"
#import "TSSQLCoreDataStack.h"
#import "Chair.h"
#import "NSManagedObject+TSCoreData.h"
#import "Table.h"

@interface TSCoreData (Tests)

@property(strong) NSMutableDictionary *threadsMappedToContexts;

@end

@interface TSSQLCoreDataStackTests : XCTestCase

@property(nonatomic, strong) TSCoreData *coreData;
@end

@implementation TSSQLCoreDataStackTests

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
    id <TSCoreDataStack> stack = [TSSQLCoreDataStack coreDataStackWithModelName:@"Test"];
    self.coreData = [TSCoreData coreDataWithCoreDataStack:stack];
}

- (void)clearCoreData {
    NSError *error = nil;
    [self.coreData clearData:&error];
    XCTAssertNil(error);
}

- (void)cleanRegisteredObjects {
    for (NSManagedObjectContext *context in self.coreData.threadsMappedToContexts.allValues) {
        [context reset];
    }
}

- (void)verifyRegisteredObjects {
    for (NSManagedObjectContext *context in self.coreData.threadsMappedToContexts.allValues) {
        XCTAssertEqual(context.registeredObjects.count, 0U);
    }
}

- (void)testClearingSQLStore {
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

- (NSArray *)fetchChairs {
    NSFetchRequest *request = [Chair fetchRequest];
    NSError *error = nil;
    NSArray *objects = [self.coreData.threadSpecificContext executeFetchRequest:request error:&error];
    return objects;
}

- (NSArray *)fetchTables {
    NSFetchRequest *request = [Table fetchRequest];
    NSError *error = nil;
    NSArray *objects = [self.coreData.threadSpecificContext executeFetchRequest:request error:&error];
    return objects;
}
@end
