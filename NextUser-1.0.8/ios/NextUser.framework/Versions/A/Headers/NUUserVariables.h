#import <Foundation/Foundation.h>

/**
 *  This class creates an user instance
 */
@interface NUUserVariables : NSObject

@property (nonatomic) NSMutableDictionary *userVariables;

- (BOOL) hasVariable:(NSString *)variableName;

- (void) addVariable:(NSString*)name withValue:(NSString*)value;

- (NSMutableDictionary *) toTrackingFormat;

@end

