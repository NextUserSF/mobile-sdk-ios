
#import <Foundation/Foundation.h>
#import "NUError.h"
#import "NSString+LGUtils.h"

typedef NS_ENUM(NSUInteger, InAppMsgLayoutType) {
    SKINNY = 0,
    MODAL,
    FULL
};

typedef NS_ENUM(NSUInteger, InAppMsgAlign) {
    CENTER = 0,
    RIGHT,
    LEFT,
    TOP,
    BOTTOM
};


typedef NS_ENUM(NSUInteger, InAppMsgAction) {
    DISMISS = 0,
    LANDING_PAGE,
    URL,
    DEEP_LINK
};

@interface InAppMessageEnumTransformer : NSObject

+(InAppMsgLayoutType) toInAppMsgType:(NSString*) type;
+(InAppMsgAlign) toInAppMsgAlign:(NSString*) align;
+(InAppMsgAction) toInAppMsgAction:(NSString*) action;

@end












