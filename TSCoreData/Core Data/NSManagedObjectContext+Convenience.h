//
//  NSManagedObjectContext+Convenience.h
//  freebee
//
//  Created by Tobias Sundstrand on 2013-05-08.
//  Copyright (c) 2013 freebee collaborations AB. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Convenience)

- (NSEntityDescription *)entityForClass:(Class) c;

@end
