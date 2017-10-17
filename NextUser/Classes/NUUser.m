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
        _nuUserVariables = [[NUUserVariables alloc] init];
    }
    
    return self;
}

- (NSString *)userIdentifier
{
    return [NUObjectPropertyStatusUtils isStringValueSet: _email] ? _email : _customerID;
}

- (BOOL) hasVariable:(NSString *)variableName
{
    if (_nuUserVariables == nil) {
        return NO;
    }
    
    return [_nuUserVariables hasVariable: variableName];
}

- (void) addVariable:(NSString*)name withValue:(NSString*)value {
    [_nuUserVariables addVariable:name withValue:value];
}

- (NSString *)httpRequestParameterRepresentation
{
    NSMutableArray *paramsArray = [NSMutableArray array];
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_email]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"email=", _email]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_customerID]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"cid=", _customerID]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_subscription]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"subscription=", _subscription]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_firstname]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"firstname=", _firstname]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_lastname]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"lastname=", _lastname]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_birthyear]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"birthyear=", _birthyear]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_country]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"country=", _country]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_state]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"state=", _state]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_zipcode]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"zipcode=", _zipcode]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_locale]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"locale=", _locale]];
    }
    
    if ([NUObjectPropertyStatusUtils isStringValueSet:_gender]) {
        [paramsArray addObject: [NSString stringWithFormat:@"%@%@", @"gender=", _gender]];
    }
    
    return [paramsArray componentsJoinedByString:@","];
}

@end
