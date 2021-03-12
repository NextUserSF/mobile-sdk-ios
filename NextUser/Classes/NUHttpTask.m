#import <Foundation/Foundation.h>
#import "NUHttpTask.h"
#import "AFNetworking.h"
#import "NUDDLog.h"

@implementation NUHttpTask

-(instancetype)initWithMethod:(NSString *)method withPath:(NSString *)url withParameters:(NSMutableDictionary *)parameters
{
    self.isAsync = YES;
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

- (void) execute: (NUHttpResponse*) responseInstance withCompletion:(void (^)(id<NUTaskResponse> responseInstance)) completionBlock
{
    NSError *error = nil;
    NSMutableURLRequest* request = [self buildRequestInstance: error];
    
    if (error) {
        completionBlock([self response: responseInstance withError:error]);
    }
    
    DDLogVerbose(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    error = nil;
    request.timeoutInterval = 20.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            completionBlock([self response: responseInstance withError:error]);
            
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        responseInstance.responseCode = (long)[httpResponse statusCode];
        if ([self successfullHttpCode:responseInstance.responseCode] == NO) {
            DDLogVerbose(@"Host for url:%@ and params:%@ responded with code :%ld and error: %@",self->path,
                         self->queryParameters, responseInstance.responseCode, [responseInstance.error localizedDescription]);
            completionBlock([self response: responseInstance withError:error]);
            
            return;
        }
        
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        responseInstance.reponseData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        [responseInstance setSuccessfull:YES];
        DDLogVerbose(@"Host for url:%@ and params:%@ responded with:%ld",self->path, self->queryParameters,
                     responseInstance.responseCode);
        completionBlock(responseInstance);
        
        }] resume];
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
