//
//  NUTrackTask.h
//  Pods
//
//  Created by Adrian Lazea on 19/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUHttpTask.h"
#import "NUTask.h"
#import "NUTrackerSession.h"

@interface NUTrackerTask : NUHttpTask
{
    NUTrackerSession* session;
    id trackObject;
}

-(instancetype)initForType:(NUTaskType)type  withTrackObject:(id) trackingObject withSession:(NUTrackerSession*) session;

@end

@interface NUTrackResponse : NUHttpResponse
{
    id trackObject;
}

- (instancetype) initWithType:(NUTaskType) type withTrackingObject:(id) trackObj;

- (id) getTrackObject;

@end
