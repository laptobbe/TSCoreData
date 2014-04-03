//
// Created by Tobias Sundstrand on 2014-04-03.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "NSManagedObject+TSCoreData.h"


@implementation NSManagedObject (TSCoreData)

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    return [self initWithEntity:[self entityWithManagedObjectContext:context] insertIntoManagedObjectContext:context];
}

+ (NSFetchRequest *)fetchRequest {
    return [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];
}

- (NSEntityDescription *)entityWithManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
}

@end