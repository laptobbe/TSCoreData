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

static TSCoreData *_sharedInstance = nil;

+ (id)sharedInstance {

    //FIXME: Should throw internal inconcistincy error here instead.
    NSAssert(_sharedInstance != nil, @"You need to call you need to init the stack once for the shared instance to be set");
    return _sharedInstance;
}

- (id)initWithCoreDataStack:(id <TSCoreDataStack>)coreDataStack {

    self = [super init];
    if (self) {
        _threadContexts = [NSMutableDictionary dictionary];
        _stack = coreDataStack;

        [self saveContextForThread:[NSThread mainThread]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextSaved:) name:NSManagedObjectContextDidSaveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadDone:) name:NSThreadWillExitNotification object:nil];
        _sharedInstance = self;
    }
    return self;
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
    NSString *mainThreadDesc = [[NSThread mainThread] description];
    return self.threadContexts[mainThreadDesc];
}

- (NSManagedObjectContext *)threadSpecificContext {
    return [self managedObjectContextForThread:[NSThread currentThread]];
}

- (NSManagedObjectContext *)managedObjectContextForThread:(NSThread *)thread {
    @synchronized (self) {
        NSManagedObjectContext *context = [self.threadContexts objectForKey:thread.description];
        if (!context) {
            [self saveContextForThread:thread];
        }
        return context;
    }
}

- (void)saveContextForThread:(NSThread *)thread {
    NSManagedObjectContext *context;
    if ([thread isEqual:[NSThread mainThread]]) {
        context = [self.stack createManagedObjectContexWithConcurrencyType:NSMainQueueConcurrencyType];
    } else {
        context = [self.stack createManagedObjectContexWithConcurrencyType:NSConfinementConcurrencyType];
    }
    [self.threadContexts setObject:context forKey:thread.description];
}

@end
