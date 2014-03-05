//
// Created by Tobias Sundstrand on 2014-03-05.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "TSAbstractCoreDataStack.h"
#import "TSAbstractCoreDataStack+private.h"

@implementation TSAbstractCoreDataStack

+ (instancetype)coreDataStackWithModelName:(NSString *)modelName {
    return [[self alloc] initWithModelName:modelName];
}

- (instancetype)initWithModelName:(NSString *)modelName {
    self = [super init];
    if (self) {
        NSManagedObjectModel *managedObjectModel = [self dataModelWithModelName:modelName];
        NSURL *storeURL = [self storeURLFromModel:modelName];
        self.persistentStoreCoordinator = [self persistentStoreCoordinatorWithManagedObjectModel:managedObjectModel storeURL:storeURL];
    }
    return self;
}

@end