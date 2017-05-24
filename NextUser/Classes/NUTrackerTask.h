//
//  NUTrackTask.h
//  Pods
//
//  Created by Adrian Lazea on 19/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUHttpTask.h"
#import "NUExecutionTask.h"

@interface NUTrackerTask : NUHttpTask <NUExecutionTask>

@property (nonatomic) NUTaskType taskType;

-(instancetype)initForType:(NUTaskType)taskType withPath:(NSString *)path withParameters:(NSDictionary *)parameters;

@end
