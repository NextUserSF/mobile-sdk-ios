//
//  NextUser.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "Nextuser.h"
#import "NextUserManager.h"

@implementation Nextuser

+ (NUTracker *) tracker
{
    return [[NextUserManager sharedInstance] getTracker];
}

@end
