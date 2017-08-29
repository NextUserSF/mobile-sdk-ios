//
//  NUWorkflow.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//
#import <Foundation/Foundation.h>
#import "NUWorkflowCondition.h"

@interface Workflow : NSObject

@property (nonatomic) NSArray<WorkflowCondition *> *conditions;
@property (nonatomic) NSString* ID;
@property (nonatomic) NSString* iamID;

- (BOOL) hasCondition:(WorkflowCondition*) condition;

@end


