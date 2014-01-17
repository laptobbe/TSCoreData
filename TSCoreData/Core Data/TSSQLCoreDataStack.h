
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TSCoreData.h"

@interface TSSQLCoreDataStack : NSObject <TSCoreDataStack>

+ (TSSQLCoreDataStack *) coreDataStackWithModelName:(NSString *)modelName error:(NSError **)error;

@end
