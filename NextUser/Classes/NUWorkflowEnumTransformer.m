//
//  NUWorkflowEnumTransformer.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import "NUWorkflowEnumTransformer.h"

@implementation WorkflowEnumTransformer

+(WorkflowRule) toWorkflowRule:(NSString*) rule
{
    if ([@"NEW_SESSION" isEqualToString:rule]) {
        return NEW_SESSION;
    } else if ([@"SCREEN_VIEW" isEqualToString:rule]) {
        return SCREEN_VIEW;
    } else if ([@"EVENT" isEqualToString:rule]) {
        return EVENT;
    } else if ([@"PURCHASE" isEqualToString:rule]) {
        return PURCHASE;
    }
    
    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected WorkflowRule: %@", rule]];
    @throw error;
}

@end

