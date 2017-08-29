//
//  NUWorkflowCondition.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUWorkflowCondition.h"

@implementation WorkflowCondition

- (BOOL)isEqual:(WorkflowCondition *)object {
    if (object != NULL && self.rule == object.rule && [self.value isEqual:object.value]) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [[NSNumber numberWithInt:self.rule] hash];
}

@end
