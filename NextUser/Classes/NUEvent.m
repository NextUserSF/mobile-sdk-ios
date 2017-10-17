//
//  NUAction.m
//  NextUserKit
//
//  Created by NextUser on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUEvent+Serialization.h"
#import "NSString+LGUtils.h"

@interface NUEvent ()

@property (nonatomic) NSString *eventName;
@property (nonatomic) NSMutableArray *params;

@end

@implementation NUEvent

+ (instancetype)eventWithName:(NSString *)eventName
{
    NUEvent *event = [[NUEvent alloc] initWithName:eventName];
    
    return event;
}

+ (instancetype)eventWithName:(NSString *)eventName andParameters:(NSMutableArray *) parameters
{
    NUEvent *event = [[NUEvent alloc] initWithName:eventName];
    event.params = parameters;
    
    return event;
}

- (id)initWithName:(NSString *)eventName
{
    if (eventName == nil || eventName.length == 0) {
        @throw [NSException exceptionWithName:@"Event create exception"
                                       reason:@"Event name must be a non-empty string"
                                     userInfo:nil];
    }
    
    if (self = [super init]) {
        _eventName = [eventName copy];
        _params = [NSMutableArray arrayWithCapacity:10];
        for (int i=0; i<10; i++) {
            [_params addObject:[NSNull null]];
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
    
    _params[index] = parameterValue;
}

#pragma mark - Trackable

- (NSString *)httpRequestParameterRepresentation
{
    return [self.class serializedActionStringFromAction:self];
}

#pragma mark - Serialization

+ (NSString *)serializedActionStringFromAction:(NUEvent *)event
{
    NSString *eventValue = [self URLParameterValueFromString:event.eventName];
    if (event.params.count > 0) {
        NSString *eventParametersString = [self serializedActionParametersStringWithActionParameters:event.params];
        if (eventParametersString.length > 0) {
            eventValue = [eventValue stringByAppendingFormat:@",%@", eventParametersString];
        }
    }
    
    return eventValue;
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
