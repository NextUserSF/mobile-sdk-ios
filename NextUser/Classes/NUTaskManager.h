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
extern NSString * const COMPLETION_HTTP_NOTIFICATION_NAME;
extern NSString * const COMPLETION_TRACKER_NOTIFICATION_NAME;
extern NSString * const COMPLETION_CUSTOM_NOTIFICATION_NAME;
extern NSString * const COMPLETION_NOTIFICATION_OBJECT_KEY;

@interface NUTaskManager : NSObject

@property NSOperationQueue *queue;

+ (instancetype)sharedManager;
- (void)addOperation:(NUConcurrentOperation *)operation;
- (void)addOperation:(NUConcurrentOperation *)operation withCompletionBlock:(void (^)(void))block;
- (void)submitHttpTask:(NUHttpTask *) task;
- (void)submitHttpTask:(NUHttpTask *) task withNUHttpCompetionBlock:(nuHttpCompletionBlock)completionBlock;

@end
