//
//  NSManagedObjectContext+Convenience.h
//
//  Created by Tobias Sundstrand on 2013-05-08.
//  Copyright (c) 2013 Tobias Sundstrand. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (TSCoreData)

- (NSEntityDescription *)entityForClass:(Class)class;

@end
