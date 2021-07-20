#import <Foundation/Foundation.h>

#import "NUJSONObject.h"

@interface NUEvent : NUJSONObject

@property (nonatomic) NSString *eventName;
@property (nonatomic) NSMutableArray *parameters;

+ (instancetype)eventWithName:(NSString *)eventName;
+ (instancetype)eventWithName:(NSString *)eventName andParameters:(NSMutableArray *) parameters;

- (void)setFirstParameter:(NSString *)firstParameter;
- (void)setSecondParameter:(NSString *)secondParameter;
- (void)setThirdParameter:(NSString *)thirdParameter;
- (void)setFourthParameter:(NSString *)fourthParameter;
- (void)setFifthParameter:(NSString *)fifthParameter;
- (void)setSixthParameter:(NSString *)sixthParameter;
- (void)setSeventhParameter:(NSString *)seventhParameter;
- (void)setEightParameter:(NSString *)eightParameter;
- (void)setNinthParameter:(NSString *)ninthParameter;
- (void)setTenthParameter:(NSString *)tenthParameter;

@end
