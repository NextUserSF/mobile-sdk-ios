//
//  NUTrackerInitializationTask.h
//  Pods
//
//  Created by Adrian Lazea on 23/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUConcurrentOperation.h"
#import "NUTaskResponse.h"
#import "NUTrackerSession.h"

@interface NUTrackerInitializationTask : NUConcurrentOperation
@end


@interface NUTrackerInitializationTaskResponse : NSObject <NUTaskResponse>

@property (nonatomic) BOOL successfull;
@property (nonatomic) NSString *error;
@property (nonatomic) NUTrackerSession *responseObject;

@end
