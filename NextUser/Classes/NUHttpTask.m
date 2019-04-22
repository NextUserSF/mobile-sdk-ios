#import <Foundation/Foundation.h>
#import "NUHttpTask.h"
#import "AFNetworking.h"
#import "NUDDLog.h"

@implementation NUHttpTask

-(instancetype)initWithMethod:(NSString *)method withPath:(NSString *)url withParameters:(NSMutableDictionary *)parameters
{
    if (self = [super init]) {
        requestMethod = method;
        path = url;
        queryParameters = parameters;
    }

    return self;
}

-(instancetype)initGetRequestWithPath: (NSString *)url withParameters:(NSMutableDictionary *)parameters
{
    return [self initWithMethod:@"GET" withPath:url withParameters:parameters];
}

- (id<NUTaskResponse>) responseInstance
{
    return [NUHttpResponse init];
}

- (NSMutableURLRequest* ) buildRequestInstance:(NSError *) error
{
    return [[AFHTTPRequestSerializer serializer] requestWithMethod: requestMethod URLString:path parameters: queryParameters error:&error];
}

- (id<NUTaskResponse>) execute: (NUHttpResponse*) responseInstance
{
    NSError *error = nil;
    NSMutableURLRequest* request = [self buildRequestInstance: error];
    
    if (error) {
        return[self response: responseInstance withError:error];
    }
    
    DDLogVerbose(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    NSHTTPURLResponse *httpResponse;
    error = nil;
    request.timeoutInterval = 20.0;
    responseInstance.reponseData  = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    responseInstance.responseCode = (long)[httpResponse statusCode];
    
    if ([self successfullHttpCode:responseInstance.responseCode] == NO) {
        DDLogVerbose(@"Host for url:%@ and params:%@ responded with code :%ld and error: %@",path, queryParameters, responseInstance.responseCode, [responseInstance.error localizedDescription]);
        return [self response: responseInstance withError:error];
    }
    
    [responseInstance setSuccessfull:YES];
    DDLogVerbose(@"Host for url:%@ and params:%@ responded with:%ld",path, queryParameters, responseInstance.
                 responseCode);
    
    return responseInstance;
}
        
-(BOOL)successfullHttpCode:(long) httpCode
{
    return httpCode >= 200 && httpCode < 300;
}

-(NUHttpResponse*) response:(NUHttpResponse*) response withError:(NSError *)error
{
    response.error = error;
    [response setSuccessfull:NO];
    
    return response;
}

- (NUTaskType) taskType
{
    return TASK_NO_TYPE;
}

@end

@implementation NUHttpResponse

@end
