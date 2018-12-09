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
-(void) setSession:(NUTrackerSession*) session;

@end
