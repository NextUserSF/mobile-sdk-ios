//
//  NUOperation.h
//  Pods
//
//  Created by Adrian Lazea on 17/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUExecutionTask.h"
#import "NUTaskType.h"
#import "NUTaskResponse.h"

@interface NUConcurrentOperation : NSOperation <NUExecutionTask>
{
    BOOL executing;
    BOOL finished;
}

@property (nonatomic) NUTaskType taskType;
@property (nonatomic) id<NUTaskResponse> responseInstance;

- (id<NUTaskResponse>) response;

@end
