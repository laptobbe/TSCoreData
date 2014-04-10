//
// Created by Tobias Sundstrand on 2014-04-03.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (TSCoreData)

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)fetchRequest;

+ (NSFetchRequest *)backgroundFetchRequest;
@end