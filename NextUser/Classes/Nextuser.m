//
//  NextUser.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NextUser.h"
#import "NextUserManager.h"

@implementation NextUser

+ (NUTracker *) tracker
{
    return [[NextUserManager sharedInstance] getTracker];
}

@end
