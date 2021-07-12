//
//  NUCustomJSCode.h
//  Pods
//
//  Created by Adrian Lazea on 09.07.2021.
//



#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NUCondition) {
    EQUALS = 0,
    CONTAINS=1,
    STARTS_WITH=2,
    ENDS_WITH=3
};

@interface NUCustomJSCode : NSObject

@property (nonatomic) NSString *jsCodeString;
@property (nonatomic) NSString *pageURL;
@property (nonatomic) NUCondition condition;

@end
