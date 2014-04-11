#import "TSSQLCoreDataStack.h"

@implementation TSSQLCoreDataStack

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel storeURL:(NSURL *)storeURL error:(NSError **)error {

    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};

    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:error]) {
        return nil;
    }
    return persistentStoreCoordinator;
}

@end
