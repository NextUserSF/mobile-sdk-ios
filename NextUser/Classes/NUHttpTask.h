//
//  NUHttpOperation.h
//  Pods
//
//  Created by Adrian Lazea on 18/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUTaskType.h"
#import "NUTaskResponse.h"
#import "AFNetworking.h"

@interface NUHttpTask : NSObject <NUTaskResponse>

@property (nonatomic) NSString *requestMethod;
@property (nonatomic) NSString *url;
@property (nonatomic) NSDictionary *parameters;
@property (nonatomic) BOOL successfull;
@property (nonatomic) NSError *error;


+ (instancetype)createWithMethod:(NSString *)method withPath:(NSString *)url withParameters:(NSDictionary *)parameters;
+ (instancetype)createGetRequesWithPath: (NSString *)url withParameters:(NSDictionary *)parameters;

- (NSURLRequest*)createNSURLRequest;
- (void)setResponseObject:(id) data;

@end
