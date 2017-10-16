//
//  NUUserVariables.m
//  NextUser
//
//  Created by Adrian Lazea on 16/10/2017.
//


#import <Foundation/Foundation.h>
#import "NUUserVariables.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"
#import "NUTrackingHTTPRequestHelper.h"

@implementation NUUserVariables

- (BOOL) hasVariable:(NSString *)variableName
{
    if(_userVariables != nil && [NUObjectPropertyStatusUtils isStringValueSet:variableName]) {
        return [NUObjectPropertyStatusUtils isStringValueSet:_userVariables[variableName]];
    }
    
    return NO;
}

- (void) addVariable:(NSString*)name withValue:(NSString*)value
{
    if (_userVariables == nil) {
        _userVariables = [[NSMutableDictionary alloc] init];
    }
    
    [_userVariables setValue:value forKey:name];
}

-(NSMutableDictionary *) toTrackingFormat
{
    if (_userVariables == nil || [_userVariables count] == 0) {
        return nil;
    }
    
    NSMutableDictionary * trackMap = [[NSMutableDictionary alloc]
                                      initWithCapacity: [_userVariables count]];
    int index = 0;
    for (id key in _userVariables.allKeys) {
        NSString *userVariableTrackKey = [NSString stringWithFormat:TRACK_SUBSCRIBER_VARIABLE_PARAM"%d", index];
        NSString *userVariableTrackValue = [NSString stringWithFormat:@"%@=%@", key,
                                            [_userVariables[key] URLEncodedString]];
        trackMap[userVariableTrackKey] = userVariableTrackValue;
        index++;
    }
    
    return trackMap;
}

@end
