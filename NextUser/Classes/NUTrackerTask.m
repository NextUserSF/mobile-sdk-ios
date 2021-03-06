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
        case NEW_IAM:
        case UNREGISTER_DEVICE_TOKENS:
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
        _queued = NO;
    }
    
    return self;
}

-(id<NUTaskResponse>) responseInstance
{
    return [[NUTrackResponse alloc] initWithType:taskType withTrackingObject:trackObject andQueued:_queued];
}

- (void) execute: (NUHttpResponse*) responseInstance withCompletion:(void (^)(id<NUTaskResponse> responseInstance)) completionBlock
{
    NSError *error = [self setupRequestData];
    if (error) {
        @throw error;
    }
    
    [super execute:responseInstance withCompletion:completionBlock];
}

-(NSError *) setupRequestData
{
    NSError *error = nil;
    switch (taskType) {
        case SESSION_INITIALIZATION:
            path = [session sessionInitPath];
            queryParameters = [NUTrackingHTTPRequestHelper sessionInitializationParameters: session];
            break;
        case IAM_CHECK_EVENT:
            path = [session checkEventPath];
            queryParameters = [NUTrackingHTTPRequestHelper generateCheckEventDictionary:trackObject withSession: session];
            break;
        case NEW_IAM:
            path = [session getIAMPath: trackObject];
            queryParameters = [NSMutableDictionary dictionary];
            break;
        case REGISTER_DEVICE_TOKEN:
            path = [session deviceTokenPath:NO];
            queryParameters = [NUTrackingHTTPRequestHelper generateDeviceTokenDictionary:trackObject];
            break;
        case UNREGISTER_DEVICE_TOKENS:
            path = [session deviceTokenPath:YES];
            queryParameters = [NSMutableDictionary dictionary];
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
        switch (taskType) {
            case REGISTER_DEVICE_TOKEN:
            case IAM_CHECK_EVENT:
                [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                break;
            default:
                [postRequest setValue:@"text/plain; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
                break;
        }
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:queryParameters options:0 error:&error];
        [postRequest setHTTPBody: jsonData];
        
        return postRequest;
    }
    
    return [super buildRequestInstance:error];
}

@end

@implementation NUTrackResponse

- (instancetype) initWithType:(NUTaskType) type withTrackingObject:(id) trackObj andQueued:(BOOL) queued
{
    if (self = [self initWithType:type shouldNotifyListeners:YES]) {
        self.trackObject = trackObj;
        self.type = type;
        self.queued = queued;
    }
    
    return self;
}

- (NSString *) taskTypeAsString
{
    switch (taskType) {
            case APPLICATION_INITIALIZATION:
            
                return @"APPLICATION_INITIALIZATION";
            case SESSION_INITIALIZATION:
            
                return @"SESSION_INITIALIZATION";
            case REQUEST_IN_APP_MESSAGES:
            
                return @"REQUEST_IN_APP_MESSAGES";
            case TRACK_EVENT:
            
                return @"TRACK_EVENT";
            case TRACK_SCREEN:
            
                return @"TRACK_SCREEN";
            case TRACK_PURCHASE:
            
                return @"TRACK_PURCHASE";
            case IMAGE_DOWNLOAD:
            
                return @"IMAGE_DOWNLOAD";
            case REGISTER_DEVICE_TOKEN:
            
                return @"REGISTER_DEVICE_TOKEN";
            case UNREGISTER_DEVICE_TOKENS:
            
                return @"UNREGISTER_DEVICE_TOKENS";
            case TRACK_USER:
            
                return @"TRACK_USER";
            case TRACK_USER_VARIABLES:
            
                return @"TRACK_USER_VARIABLES";
            case NEW_IAM:
            
                return @"NEW_IAM";
            case IAM_CHECK_EVENT:
            
                return @"IAM_CHECK_EVENT";
            case CHECK_CACHES:
            
                return @"CHECK_CACHES";
            case IAM_DISMISSED:
            
                return @"IAM_DISMISSED";
            case SOCIAL_SHARE:
            
                return @"SOCIAL_SHARE";
            case NETWORK_AVAILABLE:
            
                return @"NETWORK_AVAILABLE";
        default:
            return @"TASK_NO_TYPE";
    }
}

@end
