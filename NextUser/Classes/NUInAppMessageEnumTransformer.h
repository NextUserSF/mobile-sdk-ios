#import <Foundation/Foundation.h>
#import "NUError.h"
#import "NSString+LGUtils.h"

typedef NS_ENUM(NSUInteger, InAppMsgLayoutType) {
    SKINNY = 0,
    MODAL,
    FULL,
    NO_TYPE
};

typedef NS_ENUM(NSUInteger, InAppMsgAlign) {
    CENTER = 0,
    RIGHT,
    LEFT,
    TOP,
    BOTTOM,
    NO_ALIGN
};


typedef NS_ENUM(NSUInteger, InAppMsgAction) {
    DISMISS = 0,
    LANDING_PAGE,
    URL,
    DEEP_LINK,
    NO_ACTION
};

@interface InAppMessageEnumTransformer : NSObject

+(InAppMsgLayoutType) toInAppMsgType:(id) type;
+(InAppMsgAlign) toInAppMsgAlign:(id) align;
+(InAppMsgAction) toInAppMsgAction:(id) action;

@end












