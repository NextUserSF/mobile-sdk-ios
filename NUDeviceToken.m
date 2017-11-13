#import <Foundation/Foundation.h>
#import "NUDeviceToken.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"

@implementation NUDeviceToken

- (NSString *)httpRequestParameterRepresentation
{
    NSMutableArray *paramsArray = [NSMutableArray array];
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_deviceOS]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"device_os=", _deviceOS]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_token]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"token=", _token]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_provider]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"provider=", _provider]];
    }
    
    [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"active=", _active == YES ? @"1" : @"0"]];
    
    return [paramsArray componentsJoinedByString:@","];
}

@end
