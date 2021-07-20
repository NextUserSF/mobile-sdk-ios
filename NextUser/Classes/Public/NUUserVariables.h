#import <Foundation/Foundation.h>
#import "NUJSONObject.h"

@interface NUUserVariables : NUJSONObject

@property (nonatomic) NSMutableDictionary *variables;

- (BOOL) hasVariable:(NSString *)variableName;

- (void) addVariable:(NSString*)name withValue:(NSString*)value;

- (NSMutableDictionary *) toTrackingFormat;

@end

