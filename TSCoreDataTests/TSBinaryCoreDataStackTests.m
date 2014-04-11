//
//  TSBinaryCoreDataStackTests.m
//  TSCoreData
//
//  Created by Tobias Sundstrand on 2014-04-11.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TSCoreDataStackTestCase.h"
#import "TSAbstractCoreDataStack.h"
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

@end
