//
//  NSManagedObject+TSCoreDataTests.m
//  TSCoreData
//
//  Created by Tobias Sundstrand on 2014-04-10.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSManagedObject+TSCoreData.h"
#import "Chair.h"

@interface NSManagedObject_TSCoreDataTests : XCTestCase

@end

@implementation NSManagedObject_TSCoreDataTests

- (void)testFetchRequestForManagedObject {
    NSFetchRequest *request = [Chair fetchRequest];
    XCTAssertEqual(request.resultType, NSManagedObjectResultType);
    XCTAssertEqualObjects(request.entityName, @"Chair");
}

- (void)testBackgroundFetchRequestForManagedObject {
    NSFetchRequest *request = [Chair backgroundFetchRequest];
    XCTAssertEqual(request.resultType, NSManagedObjectIDResultType);
    XCTAssertEqualObjects(request.entityName, @"Chair");
}
@end
