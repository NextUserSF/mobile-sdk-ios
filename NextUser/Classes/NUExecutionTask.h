//
//  NUTypeOperation.h
//  Pods
//
//  Created by Adrian Lazea on 17/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUTaskType.h"

@protocol NUExecutionTask <NSObject>
- (NUTaskType) taskType;
@end
