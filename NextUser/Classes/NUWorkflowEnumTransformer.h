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

typedef NS_ENUM(NSUInteger, WorkflowRule) {
    NEW_SESSION = 0,
    SCREEN_VIEW,
    EVENT,
    PURCHASE,
    NO_RULE
};


@interface WorkflowEnumTransformer : NSObject
    +(WorkflowRule) toWorkflowRule:(NSString*) rule;
@end


















