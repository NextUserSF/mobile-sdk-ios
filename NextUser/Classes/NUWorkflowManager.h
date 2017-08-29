//
//  NUIamWorkflowManager.h
//  Pods
//
//  Created by Adrian Lazea on 11/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUTrackerSession.h"
#import "NUTask.h"


@interface NUWorkflowManager : NSObject

@property (nonatomic ) NUTrackerSession* session;

-(instancetype)initWithSession:(NUTrackerSession*) tSession;
-(void) requestInstantWorkflows:(NUTaskType) type;
-(void) removeWorkflow:(NSString*) iamID;

@end
