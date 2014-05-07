//
// Created by Tobias Sundstrand on 2014-03-05.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "TSBinaryCoreDataStack.h"

@implementation TSBinaryCoreDataStack

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel storeURL:(NSURL *)storeURL error:(NSError **)error {

    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};

    if (![persistentStoreCoordinator addPersistentStoreWithType:NSBinaryStoreType configuration:nil URL:storeURL options:options error:error]) {
        return nil;
    }

    return persistentStoreCoordinator;
}

@end