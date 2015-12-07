//
//  NUAction.m
//  NextUserKit
//
//  Created by Dino on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUAction.h"

@interface NUAction ()

@property (nonatomic) NSMutableArray *parametersMutable;

@end

@implementation NUAction

+ (NUAction *)actionWithName:(NSString *)actionName
{
    NUAction *action = [[NUAction alloc] initWithName:actionName];
    
    return action;
}

- (id)initWithName:(NSString *)actionName
{
    if (self = [super init]) {
        _actionName = [actionName copy];
        _parametersMutable = [NSMutableArray arrayWithCapacity:10];
        for (int i=0; i<10; i++) {
            [_parametersMutable addObject:[NSNull null]];
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

- (NSArray *)parameters
{
    return [_parametersMutable copy];
}

#pragma mark - Private API

- (void)updateParameterAtIndex:(NSUInteger)index withValue:(NSString *)value
{
    id parameterValue = [NSNull null];
    if (value != nil && value.length > 0) {
        parameterValue = value;
    }
    
    _parametersMutable[index] = parameterValue;
}

@end
