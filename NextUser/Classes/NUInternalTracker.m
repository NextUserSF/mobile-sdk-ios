//
//  NUInternalTracker.m
//  Pods
//
//  Created by Adrian Lazea on 08/09/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInternalTracker.h"
#import "NUAction+Serialization.h"
#import "NUError.h"
#import "NextUserManager.h"

@implementation InternalActionsTracker

+(void) trackAction:(NSString *) actionName withParams:(NSString*) paramsAsString
{
    NSArray *params = [paramsAsString componentsSeparatedByString:@","];
    if (params != nil && [params count] > 9) {
        NSError* error = [NUError nextUserErrorWithMessage: @"invalid params string provided"];
        @throw error;
    }
    
    [[[NextUserManager sharedInstance] getTracker]
            trackAction: [NUAction actionWithName:actionName andParams:[params mutableCopy]]];
}



@end
