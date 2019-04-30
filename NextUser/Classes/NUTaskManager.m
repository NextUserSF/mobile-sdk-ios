#import "NUTaskManager.h"
#import "NUConcurrentOperation.h"
#import "NUTrackerTask.h"
#import "NUTask.h"

@interface NUTaskManager ()
@property NSOperationQueue* queue;
@end

@implementation NUTaskManager

NSString * const COMPLETION_TASK_MANAGER_HTTP_REQUEST_NOTIFICATION_NAME = @"NUTaskManagerHttpRequestNotification";
NSString * const COMPLETION_HTTP_REQUEST_NOTIFICATION_OBJECT_KEY = @"NUTaskManagerHttpRequestNotifObject";
NSString * const COMPLETION_TASK_MANAGER_MESSAGE_NOTIFICATION_NAME = @"NUTaskManagerMessageNotificationName";
NSString * const COMPLETION_MESSAGE_NOTIFICATION_OBJECT_KEY = @"NUTaskManagerMessageNotifObject";
NSString * const COMPLETION_MESSAGE_NOTIFICATION_TYPE_KEY = @"NUTaskManagerMessageNotifType";

#pragma mark - Public

+ (instancetype)manager
{
    static NUTaskManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NUTaskManager alloc] init];
        instance -> _queue = [[NSOperationQueue alloc] init];
        [instance -> _queue setMaxConcurrentOperationCount:5];
        [instance -> _queue setName:@"com.nextuser.taskQueue"];
    });
    
    return instance;
}

- (void)submitTask:(NUConcurrentOperation *)operation
{
    [_queue addOperation:operation];
}

- (void)submitTask:(NUConcurrentOperation *)operation withCompletionBlock: (void (^)(void))block
{
    [operation setCompletionBlock:block];
    [_queue addOperation:operation];
}

-(void) dispatchCompletionNotification:(id<NUTaskResponse>) taskResponse {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:taskResponse forKey:COMPLETION_HTTP_REQUEST_NOTIFICATION_OBJECT_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:COMPLETION_TASK_MANAGER_HTTP_REQUEST_NOTIFICATION_NAME object:nil
                                                      userInfo:dictionary];
}

- (void) dispatchMessageNotification:(NUTaskType) type withObject:(id) object;
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
    [dictionary setObject:@(type) forKey:COMPLETION_MESSAGE_NOTIFICATION_TYPE_KEY];
    if (object != nil) {
        [dictionary setObject:object forKey:COMPLETION_MESSAGE_NOTIFICATION_OBJECT_KEY];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:COMPLETION_TASK_MANAGER_MESSAGE_NOTIFICATION_NAME object:nil
                                                      userInfo:dictionary];
}

@end
