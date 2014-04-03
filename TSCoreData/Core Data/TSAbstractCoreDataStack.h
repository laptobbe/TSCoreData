//
// Created by Tobias Sundstrand on 2014-03-05.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TSCoreData.h"

@interface TSAbstractCoreDataStack : NSObject <TSCoreDataStack>

@property(nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)coreDataStackWithModelName:(NSString *)modelName;

- (instancetype)initWithModelName:(NSString *)modelName;

/**
* Override this method in subclasses to provide a persistent store coordinator for your custom stack.
*/
- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel storeURL:(NSURL *)storeURL;

@end