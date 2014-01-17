#import "CoreDataStack.h"

@implementation CoreDataStack

+ (CoreDataStack *) coreDataStackWithModelName:(NSString *)modelName error:(NSError **)error{
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:modelName];
	
	CoreDataStack* cds = [[CoreDataStack alloc] initWithURL: storeURL
                                                  modelName: modelName
                                                  storeType: TSStoreTypeUnknown
                                                      error:error];
	
	return cds;

}

- (void) guessStoreType:(NSString*) fileExtension {
	if( fileExtension != nil && [fileExtension length] > 0)
	{
		/** Guess the Store Type */
		if( [@"BINARY" isEqualToString:[fileExtension uppercaseString]] )
		{
			self.coreDataStoreType = TSStoreTypeBinary;
		}
		else if( [@"XML" isEqualToString:[fileExtension uppercaseString]] )
		{
			self.coreDataStoreType = TSStoreTypeXML;
		}
		else if( [@"SQL" isEqualToString:[fileExtension uppercaseString]] )
		{
			self.coreDataStoreType = TSStoreTypeSQL;
		}
		else if( [@"SQLITE" isEqualToString:[fileExtension uppercaseString]] )
		{
			self.coreDataStoreType = TSStoreTypeSQL;
		}
		else
			NSLog(@"[%@] WARN: no explicit store type given, and could NOT guess the store type. Core Data will PROBABLY refuse to initialize!", [self class] );
	}
}

- (id)initWithURL:(NSURL*) url modelName:(NSString *)modelName storeType:(TSStoreType) type error:(NSError **)error{
    self = [super init];
    if (self) {
        self.databaseURL = url;
		self.modelName = modelName;
		self.coreDataStoreType = type;
		self.automaticallyMigratePreviousCoreData = YES;
		self.managedObjectModel = [self dataModelWithModelName:self.modelName];
        self.persistantStoreCoordinator = [self persistantStoreCoordinatorWithManagedObjectModel:self.managedObjectModel storeType:type error:error];
		if( self.coreDataStoreType == TSStoreTypeUnknown ) {
			[self guessStoreType:[self.databaseURL pathExtension]];
		}
    }
    return self;
}

-(NSManagedObjectModel*) dataModelWithModelName:(NSString *)modelName {
    NSString* momdPath = [[NSBundle mainBundle] pathForResource:modelName ofType:@"momd"];
    NSURL* momdURL = [NSURL fileURLWithPath:momdPath];
	return [[NSManagedObjectModel alloc] initWithContentsOfURL:momdURL];
}

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSPersistentStoreCoordinator *) persistantStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel storeType:(TSStoreType)storeType error:(NSError **)error{
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSString *storeTypeString;
    switch(storeType)
    {
        case TSStoreTypeXML:
            
#ifdef NSXMLStoreType
            storeTypeString = NSXMLStoreType;
#else
            NSAssert( FALSE, @"Apple does not allow you to use an XML store on this OS. Only available on OS X" );
#endif
            break;
            
        case TSStoreTypeBinary:
            storeTypeString = NSBinaryStoreType;
            break;
            
        case TSStoreTypeUnknown:
            storeTypeString = NSSQLiteStoreType;
            break;
            
        case TSStoreTypeSQL:
            storeTypeString = NSSQLiteStoreType;
            break;
            
        case TSStoreTypeInMemory:
            storeTypeString = NSInMemoryStoreType;
            break;
    }
    
    NSDictionary *options = nil;
    
    if( self.automaticallyMigratePreviousCoreData ) {
        options = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                   [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    }
    
    [persistentStoreCoordinator addPersistentStoreWithType:storeTypeString configuration:nil URL:self.databaseURL options:options error:error];
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext*) newManagedObjectContext{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [moc setPersistentStoreCoordinator:self.persistantStoreCoordinator];
	return moc;
}

- (void) wipeAllData {
	for( NSPersistentStore* store in [self.persistantStoreCoordinator persistentStores] ) {
		NSError *error;
		NSURL *storeURL = store.URL;
		[self.persistantStoreCoordinator removePersistentStore:store error:&error];
		[[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
        self.managedObjectModel = nil;
        self.persistantStoreCoordinator = nil;
		
		/** ... side effect: all NSFetchedResultsController's will now explode because Apple didn't code them very well */
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDestroyAllNSFetchedResultsControllers object:self];
	}
}

@end
