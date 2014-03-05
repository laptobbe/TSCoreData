//
//  Table.h
//  TSCoreData
//
//  Created by Tobias Sundstrand on 2014-03-05.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Table : NSManagedObject

@property(nonatomic, retain) NSNumber *height;
@property(nonatomic, retain) NSString *material;
@property(nonatomic, retain) NSDate *made;
@property(nonatomic, retain) NSSet *chairs;
@end

@interface Table (CoreDataGeneratedAccessors)

- (void)addChairsObject:(NSManagedObject *)value;

- (void)removeChairsObject:(NSManagedObject *)value;

- (void)addChairs:(NSSet *)values;

- (void)removeChairs:(NSSet *)values;

@end
