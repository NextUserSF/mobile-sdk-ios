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
#import "NUTaskResponse.h"

@implementation NUTaskManager

NSString * const COMPLETION_HTTP_NOTIFICATION_NAME = @"NUTaskManagerCompletionHTTPNotification";
NSString * const COMPLETION_TRACKER_NOTIFICATION_NAME = @"NUTaskManagerCompletionTrackerNotification";
NSString * const COMPLETION_CUSTOM_NOTIFICATION_NAME = @"NUTaskManagerCompletionCustomNotification";
NSString * const COMPLETION_NOTIFICATION_OBJECT_KEY = @"NUTaskManagerNotifObject";

#pragma mark - Public

+ (instancetype)sharedManager
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

#pragma mark - AddOperation

- (void)addOperation:(NUConcurrentOperation *)operation
{
    __block __weak NUConcurrentOperation *weakOp = operation;
    [operation setCompletionBlock:^(void){
    
        [self dispatchCompletionNotification: weakOp.response];
        
    }];
    [_queue addOperation:operation];
}

- (void)addOperation:(NUConcurrentOperation *)operation withCompletionBlock: (void (^)(void))block
{
    [operation setCompletionBlock:block];
    [_queue addOperation:operation];
}

- (void)submitHttpTask:(NUHttpTask *) task
{
    [self submitHttpTask:task withNUHttpCompetionBlock:nil];
}

- (void)submitHttpTask:(NUHttpTask *) task withNUHttpCompetionBlock:(nuHttpCompletionBlock)completionBlock {

    __block __typeof__(task) taskRef = task;
    [NSURLConnection sendAsynchronousRequest:[task createNSURLRequest] queue:_queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               BOOL success = error || !response || !data ? NO : YES;
                               if (completionBlock) {
                                   completionBlock(success, data, error);
                               }
                               
                               taskRef.successfull = success;
                               taskRef.error = error;
                               taskRef.responseObject = data;
                               
                               [self dispatchCompletionNotification: taskRef];
                           }];
}

-(void) dispatchCompletionNotification:(id)notificationObject {
    NSString *notificationName;
    if ([notificationObject class] == [NUTrackerTask class]) {
        notificationName = COMPLETION_TRACKER_NOTIFICATION_NAME;
    } else if ([notificationObject class] == [NUHttpTask class]) {
        notificationName = COMPLETION_HTTP_NOTIFICATION_NAME;
    } else {
        notificationName = COMPLETION_CUSTOM_NOTIFICATION_NAME;
    }
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:notificationObject forKey:COMPLETION_NOTIFICATION_OBJECT_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

@end
