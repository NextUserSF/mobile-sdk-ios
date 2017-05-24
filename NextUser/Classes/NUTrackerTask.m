//
//  NUTrackTask.m
//  Pods
//
//  Created by Adrian Lazea on 19/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUTrackerTask.h"
#import "NUTrackingHTTPRequestHelper.h"

@implementation NUTrackerTask

- (NUTaskType) taskType {
    return _taskType;
}

+(instancetype)createForType:(NUTaskType)taskType withPath:(NSString *)path withParameters:(NSDictionary *)parameters
{
    NUTrackerTask *instance = [self createGetRequesWithPath:path withParameters:parameters];
    instance.taskType = taskType;
    
    return instance;
}

@end
