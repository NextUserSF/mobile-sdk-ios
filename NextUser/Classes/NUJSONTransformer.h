//
//  NUJSONTransformer.h
//  Pods
//
//  Created by Adrian Lazea on 29/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUError.h"
#import "NSString+LGUtils.h"
#import "NUCache.h"
#import "NUInAppMessage.h"
#import "NUWorkflows.h"

@interface NUJSONTransformer : NSObject

+ (NSMutableArray<InAppMessage* >*) toInAppMessages:(id) messagesJSON;
+ (NSMutableArray<Workflow* >*) toWorkflows:(id) workflowsJSON;

@end
