//
//  NextUser.m
//  Pods
//
//  Created by Adrian Lazea on 27/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NextUser.h"

@implementation NextUser

+ (Tracker*) getTracker
{
    return [Tracker sharedTracker];
}

@end
