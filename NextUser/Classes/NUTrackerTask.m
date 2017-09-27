//
//  NUTrackTask.m
//  Pods
//
//  Created by Adrian Lazea on 19/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUTrackerTask.h"
#import "NUTrackingHTTPRequestHelper.h"

@implementation NUTrackerTask

-(instancetype)initForType:(NUTaskType)type  withTrackObject:(id) trackingObject withSession:(NUTrackerSession*) tSession
{
    self = [super initGetRequesWithPath:nil withParameters:nil];
    if (self) {
        taskType = type;
        trackObject = trackingObject;
        session = tSession;
    }
    
    return self;
}

-(id<NUTaskResponse>) responseInstance
{
    return [[NUTrackResponse alloc] initWithType:taskType withTrackingObject:trackObject];
}

- (id<NUTaskResponse>) execute: (NUHttpResponse*) responseInstance
{
    [self setupRequestData];
    responseInstance = [super execute:responseInstance];
    
    return responseInstance;
}

-(void) setupRequestData
{
    path = [session trackPath];
    switch (taskType) {
        case TRACK_SCREEN:
            queryParameters = [NUTrackingHTTPRequestHelper trackScreenParametersWithScreenName: trackObject];
            break;
        case TRACK_ACTION:
            queryParameters = [NUTrackingHTTPRequestHelper trackActionsParametersWithActions: trackObject];
            break;
        case TRACK_PURCHASE:
            queryParameters = [NUTrackingHTTPRequestHelper trackPurchasesParametersWithPurchases: trackObject];
            break;
        case TRACK_USER:
            queryParameters = [NUTrackingHTTPRequestHelper trackUserParametersWithVariables: trackObject];
            break;
        case SESSION_INITIALIZATION:
            path = [session sessionInitPath];
            queryParameters = [NUTrackingHTTPRequestHelper sessionInitializationParameters: session];
            break;
        case REQUEST_IN_APP_MESSAGES:
            path = [session iamsRequestPath];
            queryParameters = [NSMutableDictionary dictionary];
            break;
        case TRACK_USER_DEVICE:
            queryParameters = [NUTrackingHTTPRequestHelper trackUserDeviceParametersWithVariables: trackObject];
            break;
        default:
            break;
    }
    
    [NUTrackingHTTPRequestHelper appendSessionDefaultParameters:session withTrackParameters:queryParameters];
}

@end

@implementation NUTrackResponse

- (instancetype) initWithType:(NUTaskType) type withTrackingObject:(id) trackObj
{
    if (self = [self initWithType:type shouldNotifyListeners:YES]) {
        trackObject = trackObj;
    }
    
    return self;
}

- (id) getTrackObject
{
    return trackObject;
}

@end
