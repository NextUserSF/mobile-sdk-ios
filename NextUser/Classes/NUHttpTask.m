//
//  NUHttpOperation.m
//  Pods
//
//  Created by Adrian Lazea on 18/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUHttpTask.h"

@interface NUHttpTask()
@property (nonatomic) NSData *responseData;
@end

@implementation NUHttpTask

-(instancetype)initWithMethod:(NSString *)method withPath:(NSString *)url withParameters:(NSDictionary *)parameters
{
    self = [super init];
    if (self) {
        self.requestMethod = method;
        self.url = url;
        self.parameters = parameters;
    }

    return self;
}

-(instancetype)initGetRequesWithPath: (NSString *)url withParameters:(NSDictionary *)parameters
{
    return [self initWithMethod:@"Get" withPath:url withParameters:parameters];
}

- (NSURLRequest*)createNSURLRequest
{
    return [[AFHTTPRequestSerializer serializer] requestWithMethod: _requestMethod URLString:_url
                                                        parameters:_parameters error:nil];
}

- (void)setResponseObject:(id) data
{
    _responseData = data;
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
    return _responseData;
}

- (NUTaskType) taskType
{
    return TASK_NO_TYPE;
}

@end
