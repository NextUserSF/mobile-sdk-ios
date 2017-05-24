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

-(instancetype)initForType:(NUTaskType)taskType withPath:(NSString *)path withParameters:(NSDictionary *)parameters
{
    self = [super initGetRequesWithPath:path withParameters:parameters];
    if (self) {
        self.taskType = taskType;
    }
    
    return self;
}

@end
