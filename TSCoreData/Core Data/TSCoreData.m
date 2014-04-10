//
//  TSDataBaseHelper.m
//  TSDataBaseHelper
//
//  Created by Tobias Sundstrand on 2013-05-07.
//  Copyright (c) 2013 Computertalk Sweden. All rights reserved.
//

#import "TSCoreData.h"
#import "TSAbstractCoreDataStack.h"

NSString *const TSCoreDataErrorDomain = @"TSCoreDataErrorDomain";

@interface TSCoreData ()

@property(strong) NSManagedObjectContext *mainManagedObjectContext;
@property(strong) NSMutableDictionary *threadsMappedToContexts;
@property(strong) id <TSCoreDataStack> stack;

@end

@implementation TSCoreData

+ (instancetype)coreDataWithCoreDataStack:(id <TSCoreDataStack>)coreDataStack {
    return [[TSCoreData alloc] initWithCoreDataStack:coreDataStack];
}

- (id)initWithCoreDataStack:(id <TSCoreDataStack>)coreDataStack {

    self = [super init];
    if (self) {
        _threadsMappedToContexts = [NSMutableDictionary dictionary];
        _stack = coreDataStack;
        _mainManagedObjectContext = [self createContextForMainThread];
        [self storeContext:_mainManagedObjectContext forThread:[NSThread mainThread]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextSaved:) name:NSManagedObjectContextDidSaveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadDone:) name:NSThreadWillExitNotification object:nil];
    }
    return self;
}


- (void)clearData:(NSError **)error {
    [self deleteAllObjectsInContext:self.mainManagedObjectContext usingModel:self.stack.managedObjectModel withError:error];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextSaved:(NSNotification *)didSaveNotification {
    NSManagedObjectContext *mainContext = self.mainManagedObjectContext;
    NSManagedObjectContext *savedContext = didSaveNotification.object;

    if (savedContext == mainContext) {
        return;
    }

    if (mainContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [mainContext mergeChangesFromContextDidSaveNotification:didSaveNotification];
    });
}

- (void)threadDone:(NSNotification *)notification {
    @synchronized (self) {
        NSThread *thread = [notification object];
        [self deleteContextForThread:thread];
    }
}

- (NSManagedObjectContext *)threadSpecificContext {
    return [self managedObjectContextForThread:[NSThread currentThread]];
}

- (NSManagedObjectContext *)managedObjectContextForThread:(NSThread *)thread {
    @synchronized (self) {
        NSManagedObjectContext *context = [self.threadsMappedToContexts objectForKey:thread.description];
        if (!context) {
            context = [self createContextForBackgroundThread];
            [self storeContext:context forThread:thread];
        }
        return context;
    }
}

- (void)storeContext:(NSManagedObjectContext *)context forThread:(NSThread *)thread {
    [self.threadsMappedToContexts setObject:context forKey:thread.description];
}

- (void)deleteContextForThread:(NSThread *)thread {
    [self.threadsMappedToContexts removeObjectForKey:thread.description];
}

- (NSManagedObjectContext *)createContextForMainThread {
    return [self createContextForConcurrencyType:NSMainQueueConcurrencyType];
}

- (NSManagedObjectContext *)createContextForBackgroundThread {
    return [self createContextForConcurrencyType:NSConfinementConcurrencyType];
}

- (NSManagedObjectContext *)createContextForConcurrencyType:(NSManagedObjectContextConcurrencyType)type {
    NSManagedObjectContext *context = [self.stack createManagedObjectContextWithConcurrencyType:type];
    context.persistentStoreCoordinator = self.stack.persistentStoreCoordinator;
    return context;
}

- (void)deleteAllObjectsInContext:(NSManagedObjectContext *)context
                       usingModel:(NSManagedObjectModel *)model
                        withError:(NSError **)error {
    NSArray *entities = model.entities;
    for (NSEntityDescription *entityDescription in entities) {
        [self deleteAllObjectsWithEntityName:entityDescription.name
                                   inContext:context
                                   withError:error];
    }
}

- (void)deleteAllObjectsWithEntityName:(NSString *)entityName
                             inContext:(NSManagedObjectContext *)context
                             withError:(NSError **)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;

    NSArray *items = [context executeFetchRequest:fetchRequest error:error];

    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
    }

    if (context.hasChanges) {
        [context save:error];
    }
}

@end
