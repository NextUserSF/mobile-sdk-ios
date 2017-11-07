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

- (id<NUTaskResponse>) responseInstance
{
    return [[NUTrackerInitializationResponse alloc] initResponse];
}

- (id<NUTaskResponse>) execute:(NUTrackerInitializationResponse *) responseInstance
{
    NUTrackerProperties *properties = [NUTrackerProperties properties];
    if ([properties valid] == NO) {
        responseInstance.errorMessage = @"Invalid Properties..Please check Nextuser properties list";
        [responseInstance setSuccessfull:NO];
        
        return responseInstance;
    }
    
    responseInstance.session = [[NUTrackerSession alloc] initWithProperties:properties];
    [responseInstance setSuccessfull:YES];
    
    return responseInstance;
}
@end

@implementation NUTrackerInitializationResponse

-(instancetype) initResponse
{
    return [super initWithType:APPLICATION_INITIALIZATION shouldNotifyListeners:YES];
}
@end
