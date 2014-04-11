//
//  TSCoreDataStackTestCase.m
//  TSCoreData
//
//  Created by Tobias Sundstrand on 2014-04-11.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "Chair.h"
#import "Table.h"
#import "NSManagedObject+TSCoreData.h"
#import "TSAbstractCoreDataStack.h"
#import "TSCoreDataStackTestCase.h"

@implementation TSCoreDataStackTestCase

- (void)setupCoreDataWithStackClass:(Class)stackClass modelName:(NSString *)model {
    NSError *error = nil;
    id<TSCoreDataStack> stack = [[stackClass alloc] initWithModelName:model error:&error];
    XCTAssertNil(error);
    self.coreData = [TSCoreData coreDataWithCoreDataStack:stack];
    XCTAssertNotNil(self.coreData);
}
- (void)deleteCoreDataFileForModel:(NSString *)model {
   NSURL *storeURL =  [TSAbstractCoreDataStack storeURLFromModel:model];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
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
