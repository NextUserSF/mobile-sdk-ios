//
//  NSObject+NSOperationManager.m
//  Pods
//
//  Created by Adrian Lazea on 17/05/2017.
//
//

#import "NUTaskManager.h"
#import "NUConcurrentOperation.h"
#import "NUTrackerTask.h"
#import "NUTask.h"

@interface NUTaskManager ()
@property NSOperationQueue* queue;
@end

@implementation NUTaskManager

NSString * const COMPLETION_TASK_MANAGER_NOTIFICATION_NAME = @"NUTaskManagerNotification";
NSString * const COMPLETION_NOTIFICATION_OBJECT_KEY = @"NUTaskManagerNotifObject";

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
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:taskResponse forKey:COMPLETION_NOTIFICATION_OBJECT_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:COMPLETION_TASK_MANAGER_NOTIFICATION_NAME object:nil
                                                      userInfo:dictionary];
}

@end
