//
//  NUInternalTracker.h
//  Pods
//
//  Created by Adrian Lazea on 08/09/2017.
//
//

#import <Foundation/Foundation.h>

#define TRACK_ACTION_DISPLAYED @"_displayed"
#define TRACK_ACTION_INTERACTED @"_interacted"
#define TRACK_ACTION_DISMISSED @"_dismissed"

@interface InternalActionsTracker : NSObject

+(void) trackAction:(NSString *) actionName withParams:(NSString*) params;

@end

