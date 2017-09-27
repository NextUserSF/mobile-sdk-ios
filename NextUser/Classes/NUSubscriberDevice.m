//
//  NUSubscriberDevice.m
//  NextUser
//
//  Created by Adrian Lazea on 27/09/2017.
//

#import <Foundation/Foundation.h>
#import "NUSubscriberDevice.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"

@implementation NUSubscriberDevice

- (NSString *)httpRequestParameterRepresentation
{
    NSMutableArray *paramsArray = [NSMutableArray array];
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_os]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"os=", _os]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_osVersion]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"os_version=", _osVersion]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_deviceModel]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"device_model=", _deviceModel]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_resolution]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"resolution=", _resolution]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_trackingSource]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"tracking_source=", _trackingSource]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_trackingVersion]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"tracking_version=", _trackingVersion]];
    }
    
    [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"mobile=", _mobile == YES ? @"1" : @"0"]];
    [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"tablet=", _tablet == YES ? @"1" : @"0"]];

    return [paramsArray componentsJoinedByString:@","];
}

@end
