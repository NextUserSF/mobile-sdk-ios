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
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"r=", _resolution]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_trackingSource]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"src=", _trackingSource]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_trackingVersion]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"tv=", _trackingVersion]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_browser]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"br=", _browser]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_browserVersion]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"bv=", _browserVersion]];
    }
    
    [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"mobile=", _mobile == YES ? @"1" : @"0"]];
    [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"tablet=", _tablet == YES ? @"1" : @"0"]];

    return [paramsArray componentsJoinedByString:@","];
}

@end
