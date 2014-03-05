//
//  TSDataBaseHelper.h
//  TSDataBaseHelper
//
//  Created by Tobias Sundstrand on 2013-05-07.
//  Copyright (c) 2013 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObjectContext+Convenience.h"

@protocol TSCoreDataStack <NSObject>

- (NSManagedObjectContext *)createManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end

@interface TSCoreData : NSObject

@property(strong, readonly) NSManagedObjectContext *threadSpecificContext;
@property(strong, readonly) NSManagedObjectContext *mainManagedObjectContext;


+ (instancetype)sharedInstance;

+ (void)clearSharedInstance;

- (instancetype)initWithCoreDataStack:(id <TSCoreDataStack>)coreDataStack;

@end
