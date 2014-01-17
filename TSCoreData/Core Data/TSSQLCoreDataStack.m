#import "TSSQLCoreDataStack.h"

@interface TSSQLCoreDataStack ()

@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistantStoreCoordinator;
@property (nonatomic, strong) NSURL *storeURL;

@end

@implementation TSSQLCoreDataStack

+ (TSSQLCoreDataStack *) coreDataStackWithModelName:(NSString *)modelName error:(NSError **)error{
	return [[TSSQLCoreDataStack alloc] initWithModelName:modelName error:error];
}

- (id)initWithModelName:(NSString *)modelName error:(NSError **)error{
    self = [super init];
    if (self) {
		_modelName = modelName;
		_managedObjectModel = [self dataModelWithModelName:_modelName];
        _storeURL = [self storeURLFromModel:_modelName];
        _persistantStoreCoordinator = [self persistantStoreCoordinatorWithManagedObjectModel:_managedObjectModel error:error];
    }
    return self;
}

- (NSURL *)storeURLFromModel:(NSString *)modelName {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:modelName];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel*) dataModelWithModelName:(NSString *)modelName {
    NSString* momdPath = [[NSBundle mainBundle] pathForResource:modelName ofType:@"momd"];
    NSURL* momdURL = [NSURL fileURLWithPath:momdPath];
	return [[NSManagedObjectModel alloc] initWithContentsOfURL:momdURL];
}

- (NSPersistentStoreCoordinator *) persistantStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel error:(NSError **)error{
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};
    
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:options error:error];
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext*) createManagedObjectContext{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [moc setPersistentStoreCoordinator:self.persistantStoreCoordinator];
	return moc;
}

@end
