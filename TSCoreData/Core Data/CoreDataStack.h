
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kNotificationDestroyAllNSFetchedResultsControllers @"DestroyAllNSFetchedResultsControllers"

typedef enum CDSStoreType {
	TSStoreTypeUnknown,
	TSStoreTypeXML,
	TSStoreTypeSQL,
	TSStoreTypeBinary,
	TSStoreTypeInMemory
} TSStoreType;

@interface CoreDataStack : NSObject

@property(nonatomic, strong) NSURL* databaseURL;
@property(nonatomic, strong) NSString* modelName;
@property(nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property(nonatomic, strong) NSPersistentStoreCoordinator *persistantStoreCoordinator;
@property(nonatomic) TSStoreType coreDataStoreType;
@property(nonatomic) BOOL automaticallyMigratePreviousCoreData;

+ (CoreDataStack *) coreDataStackWithModelName:(NSString *)modelName error:(NSError **)error;
- (id)initWithURL:(NSURL *) url modelName:(NSString *)modelName storeType:(TSStoreType) type error:(NSError **)error;
- (void)wipeAllData;
- (NSManagedObjectContext*) newManagedObjectContext;

@end
