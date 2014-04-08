//
//  TSDataBaseHelper.m
//  TSDataBaseHelper
//
//  Created by Tobias Sundstrand on 2013-05-07.
//  Copyright (c) 2013 Computertalk Sweden. All rights reserved.
//

#import "TSCoreData.h"

@interface TSCoreData ()

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

        [self createMainContext];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextSaved:) name:NSManagedObjectContextDidSaveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadDone:) name:NSThreadWillExitNotification object:nil];
    }
    return self;
}

- (void)createMainContext {
    NSThread *mainThread = [NSThread mainThread];
    NSManagedObjectContext *mainContext = [self createContextForThread:mainThread];
    [self saveContext:mainContext thread:mainThread];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextSaved:(NSNotification *)didSaveNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *mainContext = self.mainManagedObjectContext;
        NSManagedObjectContext *savedContext = didSaveNotification.object;

        if (mainContext && ![savedContext isEqual:mainContext] && [self.threadsMappedToContexts.allValues containsObject:savedContext]) {
            [mainContext mergeChangesFromContextDidSaveNotification:didSaveNotification];
        }
    });
}

- (void)threadDone:(NSNotification *)notification {
    @synchronized (self) {
        NSThread *thread = [notification object];
        [self deleteContextForThread:thread];
    }
}

- (NSManagedObjectContext *)mainManagedObjectContext {
    return [self managedObjectContextForThread:[NSThread mainThread]];
}

- (NSManagedObjectContext *)threadSpecificContext {
    return [self managedObjectContextForThread:[NSThread currentThread]];
}

- (NSManagedObjectContext *)managedObjectContextForThread:(NSThread *)thread {
    @synchronized (self) {
        NSManagedObjectContext *context = [self.threadsMappedToContexts objectForKey:thread.description];
        if (!context) {
            context = [self createContextForThread:thread];
            [self saveContext:context thread:thread];
        }
        return context;
    }
}

- (void)saveContext:(NSManagedObjectContext *)context thread:(NSThread *)thread {
    [self.threadsMappedToContexts setObject:context forKey:thread.description];
}

- (void)deleteContextForThread:(NSThread *)thread {
    [self.threadsMappedToContexts removeObjectForKey:thread.description];
}

- (NSManagedObjectContext *)createContextForThread:(NSThread *)thread {
    NSManagedObjectContext *context;
    if ([thread isEqual:[NSThread mainThread]]) {
        context = [self.stack createManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
    } else {
        context = [self.stack createManagedObjectContextWithConcurrencyType:NSConfinementConcurrencyType];
    }
    context.persistentStoreCoordinator = self.stack.persistentStoreCoordinator;
    return context;
}

@end
