//
//  NSManagedObjectContext+Convenience.m
//  freebee
//
//  Created by Tobias Sundstrand on 2013-05-08.
//  Copyright (c) 2013 freebee collaborations AB. All rights reserved.
//

#import "NSManagedObjectContext+TSCoreData.h"
#import <objc/runtime.h>

@implementation NSManagedObjectContext (TSCoreData)

- (NSEntityDescription *)entityForClass:(Class)c {
    return [NSEntityDescription entityForName:NSStringFromClass(c) inManagedObjectContext:self];
}

@end
