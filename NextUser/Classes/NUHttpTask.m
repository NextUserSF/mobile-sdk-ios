//
//  NUHttpOperation.m
//  Pods
//
//  Created by Adrian Lazea on 18/05/2017.
//
//

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

-(instancetype)initGetRequesWithPath: (NSString *)url withParameters:(NSMutableDictionary *)parameters
{
    return [self initWithMethod:@"Get" withPath:url withParameters:parameters];
}

- (id<NUTaskResponse>) responseInstance
{
    return [NUHttpResponse init];
}

- (id<NUTaskResponse>) execute: (NUHttpResponse*) responseInstance
{
    NSError *error = nil;
    NSURLRequest* request = [[AFHTTPRequestSerializer serializer] requestWithMethod: requestMethod URLString:path
                                                                         parameters: queryParameters error:&error];
    if (error) {
        return[self response: responseInstance withError:error];
    }
    
    NSHTTPURLResponse *httpResponse;
    error = nil;
    responseInstance.reponseData  = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    responseInstance.responseCode = (long)[httpResponse statusCode];
    
    if ([self successfullHttpCode:responseInstance.responseCode] == NO) {
        DDLogVerbose(@"Host for url:%@ and params:%@ responded with:%ld",path, queryParameters, responseInstance.responseCode);
        
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
