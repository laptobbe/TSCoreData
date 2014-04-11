//
//  TSCoreDataStackTestCase.h
//  TSCoreData
//
//  Created by Tobias Sundstrand on 2014-04-11.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TSCoreData.h"
#import "TSAbstractCoreDataStack.h"

@interface TSCoreDataStackTestCase : XCTestCase

@property(nonatomic, strong) TSCoreData *coreData;

- (void)setupCoreDataWithStackClass:(Class)stackClass modelName:(NSString *)model;

- (void)deleteCoreDataFileForModel:(NSString *)model;

- (void)clearCoreData;

- (void)cleanRegisteredObjects;

- (void)verifyRegisteredObjects;

- (NSArray *)fetchChairs;

- (NSArray *)fetchTables;

@end

@interface TSCoreData (Tests)

@property(strong) NSMutableDictionary *threadsMappedToContexts;

@end

@interface TSAbstractCoreDataStack (Tests)

+ (NSURL *)storeURLFromModel:(NSString *)modelName;

@end

