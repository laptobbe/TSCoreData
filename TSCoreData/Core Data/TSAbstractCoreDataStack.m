//
// Created by Tobias Sundstrand on 2014-03-05.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "TSAbstractCoreDataStack.h"

@implementation TSAbstractCoreDataStack

+ (instancetype)coreDataStackWithModelName:(NSString *)modelName error:(NSError **)error {
    return [[self alloc] initWithModelName:modelName error:error];
}

- (instancetype)initWithModelName:(NSString *)modelName error:(NSError **)error {
    self = [super init];
    if (self) {
        _managedObjectModel = [self dataModelWithModelName:modelName];
        _storeURL = [TSAbstractCoreDataStack storeURLFromModel:modelName];
        _persistentStoreCoordinator = [self persistentStoreCoordinatorWithManagedObjectModel:_managedObjectModel storeURL:_storeURL error:error];
    }
    return self;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel storeURL:(NSURL *)storeURL error:(NSError **)error {
    NSAssert(NO, @"persistentStoreCoordinatorWithManagedObjectModel:storeURL:error: needs to be overridden in subclass");
    return nil;
}

- (NSManagedObjectContext *)createManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct {
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:ct];
    [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    return moc;
}

- (NSManagedObjectModel *)dataModelWithModelName:(NSString *)modelName {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:modelName ofType:@"momd"];
    NSURL *url = [NSURL fileURLWithPath:path];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
}

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL *)storeURLFromModel:(NSString *)modelName {
    NSString *databaseFile = [NSString stringWithFormat:@"%@.db", modelName];
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:databaseFile];
}


@end