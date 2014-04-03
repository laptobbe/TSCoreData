//
// Created by Tobias Sundstrand on 2014-03-05.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "TSAbstractCoreDataStack.h"
#import "TSAbstractCoreDataStack+subclass.h"

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

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel storeURL:(NSURL *)storeURL {
    NSAssert(NO, @"persistentStoreCoordinatorWithManagedObjectModel:storeURL: needs to be overridden in subclass");
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

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)storeURLFromModel:(NSString *)modelName {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:modelName];
}


@end