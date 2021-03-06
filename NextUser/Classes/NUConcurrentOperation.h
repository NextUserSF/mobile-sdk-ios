#import <Foundation/Foundation.h>
#import "NUTask.h"

typedef void (^nuHttpCompletionBlock)(BOOL success, NSData *responseData, NSError *error);

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

@property (nonatomic) BOOL  isAsync;

- (id<NUTaskResponse>) getTaskResponse;

@end
