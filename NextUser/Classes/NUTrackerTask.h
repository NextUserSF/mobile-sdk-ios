//
//  NUTrackTask.h
//  Pods
#import <Foundation/Foundation.h>
#import "NUHttpTask.h"
#import "NUTask.h"
#import "NUTrackerSession.h"

@interface NUTrackerTask : NUHttpTask
{
    NUTrackerSession* session;
    id trackObject;
}

@property (nonatomic) BOOL queued;

-(instancetype)initForType:(NUTaskType)type  withTrackObject:(id) trackingObject withSession:(NUTrackerSession*) session;


@end

@interface NUTrackResponse : NUHttpResponse

@property (nonatomic) id trackObject;
@property (nonatomic) NUTaskType type;
@property (nonatomic) BOOL queued;

- (instancetype) initWithType:(NUTaskType) type withTrackingObject:(id) trackObj andQueued:(BOOL) queued;
- (NSString *) taskTypeAsString;

@end
