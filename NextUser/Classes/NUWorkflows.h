//
//  NUWorkflows.h
//  Pods
//
//  Created by Adrian Lazea on 26/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUError.h"
#import "NSString+LGUtils.h"
#import "NUInAppMessage.h"

typedef NS_ENUM(NSUInteger, WorkflowRule) {
    NEW_SESSION = 0,
    SCREEN_VIEW,
    ACTION,
    PURCHASE,
    NO_RULE
};


@interface WorkflowEnumTransformer : NSObject

+(WorkflowRule) toWorkflowRule:(NSString*) rule;

@end

@implementation WorkflowEnumTransformer

+(WorkflowRule) toWorkflowRule:(NSString*) rule
{
    if ([@"NEW_SESSION" isEqualToString:rule]) {
        return NEW_SESSION;
    } else if ([@"SCREEN_VIEW" isEqualToString:rule]) {
        return SCREEN_VIEW;
    } else if ([@"ACTION" isEqualToString:rule]) {
        return ACTION;
    } else if ([@"PURCHASE" isEqualToString:rule]) {
        return PURCHASE;
    }
    
    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected WorkflowRule: %@", rule]];
    @throw error;
}

@end


//********************************************************************
//workflow condition
@interface WorkflowCondition : NSObject

@property (nonatomic) WorkflowRule rule;
@property (nonatomic) NSString* value;

@end

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
//********************************************************************


//********************************************************************
//workflow
@interface Workflow : NSObject

@property (nonatomic) NSArray<WorkflowCondition *> *conditions;
@property (nonatomic) NSString* ID;
@property (nonatomic) NSString* iamID;

- (BOOL) hasCondition:(WorkflowCondition*) condition;

@end

@implementation Workflow

- (BOOL) hasCondition:(WorkflowCondition*) condition
{
    return _conditions != nil &&
            condition != nil &&
            [_conditions containsObject:condition];
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
//********************************************************************


//********************************************************************
//instant workflow
@interface InstantWorkFlows : NSObject

@property (nonatomic) NSArray<Workflow *> *workflows;
@property (nonatomic) NSArray<InAppMessage *> *messages;

@end

@implementation InstantWorkFlows
@end
//********************************************************************










