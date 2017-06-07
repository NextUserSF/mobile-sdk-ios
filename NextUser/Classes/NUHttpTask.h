//
//  NUHttpOperation.h
//  Pods
//
//  Created by Adrian Lazea on 18/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUTask.h"

#import "NUConcurrentOperation.h"

@interface NUHttpResponse : NUConcurrentOperationResponse

@property (nonatomic) long      responseCode;
@property (nonatomic) NSError*  error;
@property (nonatomic) NSData*   reponseData;

@end


@interface NUHttpTask : NUConcurrentOperation
{
    NSString *requestMethod;
    NSString *path;
    NSMutableDictionary *queryParameters;
}

- (instancetype)initWithMethod:(NSString *)method withPath:(NSString *)url withParameters:(NSDictionary *)parameters;
- (instancetype)initGetRequesWithPath:(NSString *)url withParameters:(NSDictionary *)parameters;

@end



