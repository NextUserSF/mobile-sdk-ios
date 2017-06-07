//
//  NUOperation.h
//  Pods
//
//  Created by Adrian Lazea on 17/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUTask.h"

@interface NUConcurrentOperationResponse : NSObject <NUTaskResponse>
{
    NUTaskType taskType;
    BOOL notifyListeners;
}

@property BOOL success;

-(instancetype)initWithType:(NUTaskType) taskType shouldNotifyListeners:(BOOL) notify;
-(void)setSuccessfull:(BOOL) success;

@end

@interface NUConcurrentOperation : NSOperation <NUExecutionTask>
{
    BOOL executing;
    BOOL finished;
    NUTaskType taskType;
    id<NUTaskResponse> taskResponse;
}

-(id<NUTaskResponse>) getTaskResponse;

@end
