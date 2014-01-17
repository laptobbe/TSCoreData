//
//  TSDataBaseHelper.m
//  TSDataBaseHelper
//
//  Created by Tobias Sundstrand on 2013-05-07.
//  Copyright (c) 2013 Computertalk Sweden. All rights reserved.
//

#import "TSCoreData.h"
#import "CoreDataStack.h"

@interface TSCoreData ()

@property (atomic, strong) NSMutableDictionary *threadContexts;
@property (atomic, strong) CoreDataStack *stack;

@end

@implementation TSCoreData

static TSCoreData *sharedInstance = nil;

+ (id)sharedInstance {
    NSAssert(sharedInstance != nil, @"You need to call init with model first for the shared instance to be set");
    return sharedInstance;
}

- (id)initWithModelName:(NSString *)modelName error:(NSError **)error{
    
    self = [super init];
    if (self) {
        self.threadContexts = [NSMutableDictionary dictionary];
        self.stack = [CoreDataStack coreDataStackWithModelName:modelName error:error];
        [self.stack setCoreDataStoreType:TSStoreTypeSQL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextSaved:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(threadDone:)
                                                     name:NSThreadWillExitNotification
                                                   object:nil];
        sharedInstance = self;
    }
    return self;
}

- (void)clear {
    [[self stack] wipeAllData];
    [[self threadContexts] removeAllObjects];
}

- (void)contextSaved:(NSNotification *)didSaveNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *mainThreadDesc = [[NSThread mainThread] description];
        NSManagedObjectContext *mainContext = self.threadContexts[mainThreadDesc];
        NSManagedObjectContext *savedContext = didSaveNotification.object;
        
        if (mainContext && didSaveNotification.object != mainContext && [self.threadContexts objectForKey:savedContext.description]) {
            [mainContext mergeChangesFromContextDidSaveNotification:didSaveNotification];
            
        }
    });
}

- (void)threadDone:(NSNotification *)notification {
    [self.threadContexts removeObjectForKey:[[notification object] description]];
}

- (void)sendRequest:(NSFetchRequest *)fetchRequest withHandleBlock:(TSCoreDataFetchBlock)block{
    [self accessWithHandleBlock:^(NSManagedObjectContext *context) {
        NSError *error = nil;
        NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
        block(context, result, error);
    }];
}

- (void)accessAndSaveWithHandleBlock:(TSCoreDataAccessBlock)block saveError:(NSError **)error{
    [self accessWithHandleBlock:^(NSManagedObjectContext *context) {
        block(context);
        [self save:context error:error];
    }];
}


- (void)accessWithHandleBlock:(TSCoreDataAccessBlock)block{
    @synchronized(self){
        block([self context]);
    }
}

- (NSManagedObjectContext *) newManagedObjectContext{
    return [[self stack] newManagedObjectContext];
}

- (NSManagedObjectContext *) context {
    return [self managedObjectContextForThread:[NSThread currentThread]];
}

- (void)save:(NSManagedObjectContext *) context error:(NSError **)error{
    if (![context hasChanges]) {
        return;
    }
    
    NSError *saveError = nil;
    [context save:&saveError];
    if (saveError) {
        *error = saveError;
    }
}

- (NSManagedObjectContext *)managedObjectContextForThread:(NSThread *)thread {
    @synchronized(self){
        NSManagedObjectContext *context = [self.threadContexts objectForKey:thread.description];
        if (!context) {
            context = [self.stack newManagedObjectContext];
            [self.threadContexts setObject:context forKey:thread.description];
        }
        return context;
    }
}

@end
