//
//  NSObject+NSOperationManager.h
//  Pods
//
//  Created by Adrian Lazea on 17/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUConcurrentOperation.h"
#import "NUHttpTask.h"

typedef void (^nuHttpCompletionBlock)(BOOL success, NSData *responseData, NSError *error);
extern NSString * const COMPLETION_TASK_MANAGER_NOTIFICATION_NAME;
extern NSString * const COMPLETION_NOTIFICATION_OBJECT_KEY;

@interface NUTaskManager : NSObject

+ (instancetype)manager;
- (void)submitTask:(NUConcurrentOperation *)operation;
- (void)submitTask:(NUConcurrentOperation *)operation withCompletionBlock:(void (^)(void))block;
- (void) dispatchCompletionNotification:(id<NUTaskResponse>) taskResponse;

@end
