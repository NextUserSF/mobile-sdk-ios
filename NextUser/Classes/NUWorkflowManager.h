//
//  NUIamWorkflowManager.h
//  Pods
//
//  Created by Adrian Lazea on 11/07/2017.
//
//
//
#import <Foundation/Foundation.h>
#import "NUTrackerSession.h"
#import "NUTask.h"


@interface WorkflowManager : NSObject

+(instancetype)initWithSession:(NUTrackerSession*) tSession;
-(void) requestInstantWorkflows:(NUTaskType) type;
-(void) removeWorkflow:(NSString*) iamID;
-(void) setSession:(NUTrackerSession*) session;

@end
