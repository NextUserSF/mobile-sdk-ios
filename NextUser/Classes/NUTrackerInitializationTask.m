//
//  NUTrackerInitializationTask.m
//  Pods
//
//  Created by Adrian Lazea on 23/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUTrackerInitializationTask.h"
#import "NUTrackerProperties.h"


@implementation NUTrackerInitializationTask

-(NUTrackerInitializationTaskResponse *) execute
{
    
    NUTrackerInitializationTaskResponse *response = [NUTrackerInitializationTaskResponse alloc];
    
    NUTrackerProperties *properties = [NUTrackerProperties properties];
    if (![properties validProps]) {
        response.error = @"Invalid Properties..Please check Nextuser properties list";
        response.successfull = NO;
        
        return response;
    }
    
    response.responseObject = [NUTrackerSession initializeWithProperties:properties];
    response.successfull = YES;
    
    return response;
}

@end

@implementation NUTrackerInitializationTaskResponse

- (BOOL) successfull
{
    return _successfull;
}

- (NSString *) error
{
    return _error;
}

- (NUTrackerSession *) responseObject
{
    return _responseObject;
}

- (NUTaskType) taskType
{
    return APPLICATION_INITIALIZATION;
}

@end
