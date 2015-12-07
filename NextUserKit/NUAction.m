//
//  NUAction.m
//  NextUserKit
//
//  Created by Dino on 12/7/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import "NUAction.h"

@interface NUAction ()

// R+W public property
@property (nonatomic) NSArray *parameters;

@end

@implementation NUAction

+ (NUAction *)actionWithName:(NSString *)actionName
{
    return [[NUAction alloc] initWithName:actionName];
}

+ (NUAction *)actionWithName:(NSString *)actionName
              firstParameter:(NSString *)firstParameter
             secondParameter:(NSString *)secondParameter
              thirdParameter:(NSString *)thirdParameter
             fourthParameter:(NSString *)fourthParameter
              fifthParameter:(NSString *)fifthParameter
              sixthParameter:(NSString *)sixthParameter
            seventhParameter:(NSString *)seventhParameter
              eightParameter:(NSString *)eightParameter
              ninthParameter:(NSString *)ninthParameter
              tenthParameter:(NSString *)tenthParameter
{
    NUAction *action = [[NUAction alloc] initWithName:actionName];
    
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:10];
    [NUAction appendParameter:firstParameter toParametersArray:parameters];
    [NUAction appendParameter:secondParameter toParametersArray:parameters];
    [NUAction appendParameter:thirdParameter toParametersArray:parameters];
    [NUAction appendParameter:fourthParameter toParametersArray:parameters];
    [NUAction appendParameter:fifthParameter toParametersArray:parameters];
    [NUAction appendParameter:sixthParameter toParametersArray:parameters];
    [NUAction appendParameter:seventhParameter toParametersArray:parameters];
    [NUAction appendParameter:eightParameter toParametersArray:parameters];
    [NUAction appendParameter:ninthParameter toParametersArray:parameters];
    [NUAction appendParameter:tenthParameter toParametersArray:parameters];
    action.parameters = parameters;
    
    return action;
}

- (id)initWithName:(NSString *)name
{
    if (self = [super init]) {
        _actionName = [name copy];
    }
    
    return self;
}

#pragma mark -

+ (void)appendParameter:(NSString *)parameter toParametersArray:(NSMutableArray *)parameters
{
    if (parameter != nil) {
        [parameters addObject:parameter];
    } else {
        [parameters addObject:[NSNull null]];
    }
}

@end
