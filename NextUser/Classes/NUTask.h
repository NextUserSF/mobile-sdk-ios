//
//  NUTaskNotificationHandler.h
//  Pods
//
//  Created by Adrian Lazea on 26/05/2017.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NUTaskType) {
    APPLICATION_INITIALIZATION = 0,
    SESSION_INITIALIZATION,
    REQUEST_IN_APP_MESSAGES,
    TRACK_ACTION,
    TRACK_SCREEN,
    TRACK_PURCHASE,
    IMAGE_DOWNLOAD,
    TRACK_DEVICE,
    TRACK_USER,
    TRACK_USER_VARIABLES,
    TASK_NO_TYPE
};

@protocol NUTaskResponse <NSObject>
- (BOOL) successfull;
- (NUTaskType) taskType;
- (BOOL) notifyListeners;
@end

@protocol NUExecutionTask <NSObject>
- (id<NUTaskResponse>) responseInstance;
- (id<NUTaskResponse>) execute:(id<NUTaskResponse>) responseInstance;
@end




