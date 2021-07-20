//
//  NUCustomJSCode.m
//  NextUser
//
//  Created by Adrian Lazea on 09.07.2021.
//

#import <Foundation/Foundation.h>
#import "NUCustomJSCode.h"

@implementation NUCustomJSCode

+(instancetype) customJSCodeWithContionString:(NSString*) conditionString
{
    NUCustomJSCode *jsCode = [[NUCustomJSCode alloc] init];
    if (conditionString == nil || [conditionString isEqual:@""] || [conditionString isEqual:@"EQUALS"]) {
        jsCode.condition = EQUALS;
    } else if ([conditionString isEqual:@"CONTAINS"]) {
        jsCode.condition = CONTAINS;
    } else if ([conditionString isEqual:@"STARTS_WITH"]) {
        jsCode.condition = STARTS_WITH;
    } else if ([conditionString isEqual:@"ENDS_WITH"]) {
        jsCode.condition = ENDS_WITH;
    } else {
        jsCode.condition = EQUALS;
    }
    
    return jsCode;
}

@end
