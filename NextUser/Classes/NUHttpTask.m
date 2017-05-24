//
//  NUHttpOperation.m
//  Pods
//
//  Created by Adrian Lazea on 18/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUHttpTask.h"


@implementation NUHttpTask

NSData *responseObject;

+ (instancetype)createWithMethod:(NSString *)method withPath:(NSString *)url withParameters:(NSDictionary *)parameters
{
    
    NUHttpTask *task = [NUHttpTask alloc];
    task.requestMethod = method;
    task.url = url;
    task.parameters = parameters;
    
    return task;
}

+ (instancetype)createGetRequesWithPath: (NSString *)url withParameters:(NSDictionary *)parameters
{
    return [self createWithMethod:@"Get" withPath:url withParameters:parameters];
}

- (NSURLRequest*)createNSURLRequest
{
    return [[AFHTTPRequestSerializer serializer] requestWithMethod: _requestMethod URLString:_url
                                                        parameters:_parameters error:nil];
}

- (void)setResponseObject:(id) data
{
    responseObject = data;
}

- (BOOL) successfull
{
    return _successfull;
}

- (NSError *) error
{
    return _error;
}

- (id) responseObject
{
    return responseObject;
}

- (NUTaskType) taskType
{
    return TASK_NO_TYPE;
}

@end
