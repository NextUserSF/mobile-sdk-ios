#import <Foundation/Foundation.h>
#import "NUConcurrentOperation.h"
#import "NUHttpTask.h"

typedef void (^nuHttpCompletionBlock)(BOOL success, NSData *responseData, NSError *error);
extern NSString * const COMPLETION_TASK_MANAGER_HTTP_REQUEST_NOTIFICATION_NAME;
extern NSString * const COMPLETION_HTTP_REQUEST_NOTIFICATION_OBJECT_KEY;
extern NSString * const COMPLETION_TASK_MANAGER_MESSAGE_NOTIFICATION_NAME;
extern NSString * const COMPLETION_MESSAGE_NOTIFICATION_TYPE_KEY;
extern NSString * const COMPLETION_MESSAGE_NOTIFICATION_OBJECT_KEY;

@interface NUTaskManager : NSObject

+ (instancetype)manager;
- (void)submitTask:(NUConcurrentOperation *)operation;
- (void)submitTask:(NUConcurrentOperation *)operation withCompletionBlock:(void (^)(void))block;
- (void) dispatchCompletionNotification:(id<NUTaskResponse>) taskResponse;
- (void) dispatchMessageNotification:(NUTaskType) type withObject:(id) object;

@end
