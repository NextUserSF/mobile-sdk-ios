#import <Foundation/Foundation.h>

@interface NUUserVariables : NSObject

@property (nonatomic) NSMutableDictionary *variables;

- (BOOL) hasVariable:(NSString *)variableName;

- (void) addVariable:(NSString*)name withValue:(NSString*)value;

- (NSMutableDictionary *) toTrackingFormat;

@end

