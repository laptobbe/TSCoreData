//
//  TSDataBaseHelper.m
//  TSDataBaseHelper
//
//  Created by Tobias Sundstrand on 2013-05-07.
//  Copyright (c) 2013 Computertalk Sweden. All rights reserved.
//

#import "TSCoreData.h"

@interface TSCoreData ()

@property(atomic, strong) NSMutableDictionary *threadContexts;
@property(atomic, strong) id <TSCoreDataStack> stack;

@end

@implementation TSCoreData

+ (instancetype)coreDataWithCoreDataStack:(id <TSCoreDataStack>)coreDataStack {
    return [[TSCoreData alloc] initWithCoreDataStack:coreDataStack];
}

- (id)initWithCoreDataStack:(id <TSCoreDataStack>)coreDataStack {

    self = [super init];
    if (self) {
        _threadContexts = [NSMutableDictionary dictionary];
        _stack = coreDataStack;

        [self saveMainContext];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextSaved:) name:NSManagedObjectContextDidSaveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadDone:) name:NSThreadWillExitNotification object:nil];
    }
    return self;
}

- (void)saveMainContext {
    NSThread *mainThread = [NSThread mainThread];
    [self saveContext:[self createContextForThread:mainThread] thread:mainThread];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextSaved:(NSNotification *)didSaveNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *mainContext = self.mainManagedObjectContext;
        NSManagedObjectContext *savedContext = didSaveNotification.object;

        if (mainContext && didSaveNotification.object != mainContext && [self.threadContexts objectForKey:savedContext.description] != nil) {
            [mainContext mergeChangesFromContextDidSaveNotification:didSaveNotification];
        }
    });
}

- (void)threadDone:(NSNotification *)notification {
    @synchronized (self) {
        [self.threadContexts removeObjectForKey:[[notification object] description]];
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
        NSManagedObjectContext *context = [self.threadContexts objectForKey:thread.description];
        if (!context) {
            context = [self createContextForThread:thread];
            [self saveContext:context thread:thread];
        }
        return context;
    }
}

- (void)saveContext:(NSManagedObjectContext *)context thread:(NSThread *)thread {
    [self.threadContexts setObject:context forKey:thread.description];
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
