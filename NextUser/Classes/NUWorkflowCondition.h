//
//  NUWorkflowCondition.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUWorkflowEnumTransformer.h"

@interface WorkflowCondition : NSObject

@property (nonatomic) WorkflowRule rule;
@property (nonatomic) NSString* value;

@end


