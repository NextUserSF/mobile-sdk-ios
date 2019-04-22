#import <Foundation/Foundation.h>
#import "NUInAppMessageEnumTransformer.h"
#import "NUJSONObject.h"

@interface InAppMsgClick : NUJSONObject

@property (nonatomic) InAppMsgAction action;
@property (nonatomic) NSString *value;
@property (nonatomic) NSArray *trackEvents;

@end
