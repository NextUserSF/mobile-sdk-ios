//
//  NUWorkflow.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUWorkflow.h"

@implementation Workflow

- (BOOL) hasCondition:(WorkflowCondition*) condition
{
    return self.conditions != nil && condition != nil && [self.conditions containsObject:condition];
}

- (BOOL)isEqual:(Workflow *)object {
    if (object != NULL && [self.ID isEqual: object.ID]) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [self.ID hash];
}

@end
