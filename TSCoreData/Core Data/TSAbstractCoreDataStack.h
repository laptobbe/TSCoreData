//
// Created by Tobias Sundstrand on 2014-03-05.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TSCoreData.h"

@protocol TSCoreDataStack <NSObject>

- (NSManagedObjectContext *)createManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;

@end

@interface TSAbstractCoreDataStack : NSObject <TSCoreDataStack>

@property(nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic, strong) NSURL *storeURL;
@property(nonatomic, strong) NSManagedObjectModel *managedObjectModel;

+ (instancetype)coreDataStackWithModelName:(NSString *)modelName error:(NSError **)error;

- (instancetype)initWithModelName:(NSString *)modelName error:(NSError **)error;

/**
* Override this method in subclasses to provide a persistent store coordinator for your custom stack.
*/
- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel storeURL:(NSURL *)storeURL error:(NSError **)error;

@end