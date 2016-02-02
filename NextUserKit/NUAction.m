//
//  NUAction.m
//  NextUserKit
//
//  Created by NextUser on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUAction+Serialization.h"
#import "NSString+LGUtils.h"

@interface NUAction ()

@property (nonatomic) NSString *actionName;
@property (nonatomic) NSMutableArray *parameters;

@end

@implementation NUAction

+ (instancetype)actionWithName:(NSString *)actionName
{
    NUAction *action = [[NUAction alloc] initWithName:actionName];
    
    return action;
}

- (id)initWithName:(NSString *)actionName
{
    if (actionName == nil || actionName.length == 0) {
        @throw [NSException exceptionWithName:@"Action create exception"
                                       reason:@"Action name must be a non-empty string"
                                     userInfo:nil];
    }
    
    if (self = [super init]) {
        _actionName = [actionName copy];
        _parameters = [NSMutableArray arrayWithCapacity:10];
        for (int i=0; i<10; i++) {
            [_parameters addObject:[NSNull null]];
        }
    }
    
    return self;
}

- (void)setFirstParameter:(NSString *)firstParameter
{
    [self updateParameterAtIndex:0 withValue:firstParameter];
}

- (void)setSecondParameter:(NSString *)secondParameter
{
    [self updateParameterAtIndex:1 withValue:secondParameter];
}

- (void)setThirdParameter:(NSString *)thirdParameter
{
    [self updateParameterAtIndex:2 withValue:thirdParameter];
}

- (void)setFourthParameter:(NSString *)fourthParameter
{
    [self updateParameterAtIndex:3 withValue:fourthParameter];
}

- (void)setFifthParameter:(NSString *)fifthParameter
{
    [self updateParameterAtIndex:4 withValue:fifthParameter];
}

- (void)setSixthParameter:(NSString *)sixthParameter
{
    [self updateParameterAtIndex:5 withValue:sixthParameter];
}

- (void)setSeventhParameter:(NSString *)seventhParameter
{
    [self updateParameterAtIndex:6 withValue:seventhParameter];
}

- (void)setEightParameter:(NSString *)eightParameter
{
    [self updateParameterAtIndex:7 withValue:eightParameter];
}

- (void)setNinthParameter:(NSString *)ninthParameter
{
    [self updateParameterAtIndex:8 withValue:ninthParameter];
}

- (void)setTenthParameter:(NSString *)tenthParameter
{
    [self updateParameterAtIndex:9 withValue:tenthParameter];
}

#pragma mark - Private API

- (void)updateParameterAtIndex:(NSUInteger)index withValue:(NSString *)value
{
    id parameterValue = [NSNull null];
    if (value != nil && value.length > 0) {
        parameterValue = value;
    }
    
    _parameters[index] = parameterValue;
}

#pragma mark - Trackable

- (NSString *)httpRequestParameterRepresentation
{
    return [self.class serializedActionStringFromAction:self];
}

#pragma mark - Serialization

+ (NSString *)serializedActionStringFromAction:(NUAction *)action
{
    NSString *actionValue = [self URLParameterValueFromString:action.actionName];
    if (action.parameters.count > 0) {
        NSString *actionParametersString = [self serializedActionParametersStringWithActionParameters:action.parameters];
        if (actionParametersString.length > 0) {
            actionValue = [actionValue stringByAppendingFormat:@",%@", actionParametersString];
        }
    }
    
    return actionValue;
}

+ (NSString *)serializedActionParametersStringWithActionParameters:(NSArray *)actionParameters
{
    NSMutableString *parametersString = [NSMutableString stringWithString:@""];
    
    // max 10 parameters are allowed
    if (actionParameters.count > 10) {
        actionParameters = [actionParameters subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    // first, truncate trailing NSNull(s) of the input array
    // e.g.
    // [A, B, NSNull, NSNull, C, D, NSNull, NSNull, NSNull, NSNull]
    // -->
    // [A, B, NSNull, NSNull, C, D]
    BOOL hasAtLeastOneNonNullValue = NO;
    NSUInteger lastNonNullIndex = actionParameters.count-1;
    for (int i=(int)(actionParameters.count-1); i>=0; i--) {
        id valueAtIndex = actionParameters[i];
        if (![valueAtIndex isEqual:[NSNull null]]) {
            lastNonNullIndex = i;
            hasAtLeastOneNonNullValue = YES;
            break;
        }
    }
    
    if (hasAtLeastOneNonNullValue) {
        NSArray *truncatedParameters = [actionParameters subarrayWithRange:NSMakeRange(0, lastNonNullIndex+1)];
        if (truncatedParameters.count > 0) {
            for (int i=0; i<truncatedParameters.count; i++) {
                if (i > 0) { // add comma before adding each parameter except for the first one
                    [parametersString appendString:@","];
                }
                
                id actionParameter = truncatedParameters[i];
                if (![actionParameter isEqual:[NSNull null]]) {
                    [parametersString appendString:[self URLParameterValueFromString:actionParameter]];
                }
            }
        }
    }
    
    return [parametersString copy];
}

+ (NSString *)URLParameterValueFromString:(NSString *)parameterValue
{
    return [parameterValue URLEncodedString];
}

@end
