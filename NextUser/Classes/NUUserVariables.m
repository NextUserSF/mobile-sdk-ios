#import <Foundation/Foundation.h>
#import "NUUserVariables.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"
#import "NUTrackingHTTPRequestHelper.h"

@implementation NUUserVariables

- (BOOL) hasVariable:(NSString *)variableName
{
    if(_variables != nil && [NUObjectPropertyStatusUtils isStringValueSet:variableName]) {
        return [NUObjectPropertyStatusUtils isStringValueSet:_variables[variableName]];
    }
    
    return NO;
}

- (void) addVariable:(NSString*)name withValue:(NSString*)value
{
    if (_variables == nil) {
        _variables = [[NSMutableDictionary alloc] init];
    }
    
    [_variables setValue:value forKey:name];
}

-(NSMutableDictionary *) toTrackingFormat
{
    if (_variables == nil || [_variables count] == 0) {
        return nil;
    }
    
    NSMutableDictionary * trackMap = [[NSMutableDictionary alloc]
                                      initWithCapacity: [_variables count]];
    int index = 0;
    for (id key in _variables.allKeys) {
        NSString *userVariableTrackKey = [NSString stringWithFormat:TRACK_SUBSCRIBER_VARIABLE_PARAM"%d", index];
        NSString *userVariableTrackValue = [NSString stringWithFormat:@"%@=%@", key,
                                            [_variables[key] URLEncodedString]];
        trackMap[userVariableTrackKey] = userVariableTrackValue;
        index++;
    }
    
    return trackMap;
}

@end
