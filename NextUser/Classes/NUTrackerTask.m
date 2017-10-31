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
#import "AFNetworking.h"

@implementation NUTrackerTask

-(instancetype)initForType:(NUTaskType)type  withTrackObject:(id) trackingObject withSession:(NUTrackerSession*) tSession
{
    requestMethod = @"POST";
    switch (type) {
        case SESSION_INITIALIZATION:
        case REQUEST_IN_APP_MESSAGES:
            requestMethod = @"GET";
            break;
        default:
            break;
    }
    
    self = [super initWithMethod:requestMethod withPath:path withParameters:queryParameters];
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
    NSError *error = [self setupRequestData];
    if (error) {
        return [self response:responseInstance withError:error];
    }
    
    responseInstance = [super execute:responseInstance];
    
    return responseInstance;
}

-(NSError *) setupRequestData
{
    NSError *error = nil;
    switch (taskType) {
        case SESSION_INITIALIZATION:
            path = [session sessionInitPath];
            queryParameters = [NUTrackingHTTPRequestHelper sessionInitializationParameters: session];
            break;
        case REQUEST_IN_APP_MESSAGES:
            path = [session iamsRequestPath];
            queryParameters = [NSMutableDictionary dictionary];
            [NUTrackingHTTPRequestHelper appendSessionDefaultParameters:session withTrackParameters:queryParameters];
            break;
        default:
            path = [NSString stringWithFormat:@"%@?%@=%@", [session trackCollectPath], @"tid", [NUTrackingHTTPRequestHelper generateTid:session]];
            queryParameters = [NUTrackingHTTPRequestHelper generateCollectDictionary:taskType withObject:trackObject withSession:session];
            if (queryParameters == nil) {
                error = [[NSError alloc] init];
                [error setValue:@"Invalid json params" forKey:@"Description"];
            }
            break;
    }
    
    return error;
}

-(NSMutableURLRequest *)buildRequestInstance:(NSError *)error
{
    if ([requestMethod isEqualToString:@"POST"]) {
        NSMutableURLRequest *postRequest = [[AFHTTPRequestSerializer serializer] requestWithMethod: requestMethod URLString:path parameters: nil error:&error];
        [postRequest setValue:@"text/plain; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:queryParameters options:0 error:&error];
        [postRequest setHTTPBody: jsonData];
        
        return postRequest;
    }
    
    return [super buildRequestInstance:error];
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
