//
//  NUTrackerInitializationTask.h
//  Pods
//
//  Created by Adrian Lazea on 23/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUConcurrentOperation.h"
#import "NUTask.h"
#import "NUTrackerSession.h"

@interface NUTrackerInitializationTask : NUConcurrentOperation
@end


@interface NUTrackerInitializationResponse : NUConcurrentOperationResponse

@property (nonatomic) NUTrackerSession *session;
@property (nonatomic) NSString *errorMessage;

-(instancetype) initResponse;

@end
