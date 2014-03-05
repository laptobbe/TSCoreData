//
// Created by Tobias Sundstrand on 2014-03-05.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TSAbstractCoreDataStack.h"

@interface TSAbstractCoreDataStack (
private)

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel storeURL:(NSURL *)storeURL;

- (NSManagedObjectModel *)dataModelWithModelName:(NSString *)modelName;

- (NSURL *)applicationDocumentsDirectory;

- (NSURL *)storeURLFromModel:(NSString *)modelName;

- (NSManagedObjectContext *)createManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct;

@end