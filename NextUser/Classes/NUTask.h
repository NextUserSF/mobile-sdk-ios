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
    SESSION_INITIALIZATION = 1,
    TRACK_ACTION = 2,
    TRACK_SCREEN = 3,
    TRACK_PURCHASE = 4,
    IMAGE_DOWNLOAD = 5,
    TRACK_DEVICE = 6,
    TRACK_USER = 7,
    TRACK_USER_VARIABLES = 8,
    TASK_NO_TYPE = 9
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




