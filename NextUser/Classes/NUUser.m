//
//  NSObject+NUUser.m
//  Pods
//
//  Created by Adrian Lazea on 28/04/2017.
//
//

#import "NUUser.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"


@implementation NUUser

+ (instancetype)user
{
    return [[NUUser alloc] init];
}

- (id)init
{
    if (self = [super init]) {
        _userVariables = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSString *)userIdentifier
{
    return [NUObjectPropertyStatusUtils isStringValueSet: _email] ? _email : _uid;
}

- (BOOL) hasVariable:(NSString *)variableName
{
    if ([NUObjectPropertyStatusUtils isStringValueSet:variableName]) {
        return [NUObjectPropertyStatusUtils isStringValueSet:_userVariables[variableName]];
    }
    
    return NO;
}

- (void) addVariable:(NSString*)name withValue:(NSString*)value {
    [_userVariables setValue:value forKey:name];
}

- (NSString *)httpRequestParameterRepresentation
{
    NSMutableArray *paramsArray = [NSMutableArray array];
    
    //if ([NUObjectPropertyStatusUtils isStringValueSet:_email]) {
    //    [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"email=", [_email URLEncodedString]]];
    //}
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_uid]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"uid=", [ _uid URLEncodedString]]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_subscription]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"subscription=", [_subscription URLEncodedString]]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_firstname]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"firstname=", [_firstname URLEncodedString]]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_lastname]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"lastname=", [_lastname URLEncodedString]]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_birthyear]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"birthyear=", [_birthyear URLEncodedString]]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_country]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"country=", [_country URLEncodedString]]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_state]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"state=", [_state URLEncodedString]]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_zipcode]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"zipcode=", [_zipcode URLEncodedString]]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_locale]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"locale=", [_locale URLEncodedString]]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_gender]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"gender=", [_gender URLEncodedString]]];
    }
    
    return [paramsArray componentsJoinedByString:@","];
}

@end
