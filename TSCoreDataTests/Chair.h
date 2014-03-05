//
//  Chair.h
//  TSCoreData
//
//  Created by Tobias Sundstrand on 2014-03-05.
//  Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Table;

@interface Chair : NSManagedObject

@property(nonatomic, retain) NSNumber *height;
@property(nonatomic, retain) NSString *material;
@property(nonatomic, retain) Table *table;

@end
