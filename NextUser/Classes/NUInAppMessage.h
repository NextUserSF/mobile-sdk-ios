
#import <Foundation/Foundation.h>
#import "NUError.h"
#import "NSString+LGUtils.h"

//********************************************************************
//enums
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

@implementation InAppMessageEnumTransformer

+(InAppMsgLayoutType) toInAppMsgType:(NSString*) type
{
    if ([@"SKINNY" isEqualToString:type]) {
        return SKINNY;
    } else if ([@"MODAL" isEqualToString:type]) {
        return MODAL;
    } else if ([@"FULL" isEqualToString:type]) {
        return FULL;
    }

    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected InAppMsgLayoutType: %@", type]];
    @throw error;
}

+(InAppMsgAlign) toInAppMsgAlign:(NSString*) align
{
    if ([@"center" isEqualToString:align]) {
        return CENTER;
    } else if ([@"right" isEqualToString:align]) {
        return RIGHT;
    } else if ([@"left" isEqualToString:align]) {
        return LEFT;
    } else if ([@"top" isEqualToString:align]) {
        return TOP;
    } else if ([@"bottom" isEqualToString:align]) {
        return BOTTOM;
    }
    
    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected InAppMsgAlign: %@", align]];
    @throw error;
}

+(InAppMsgAction) toInAppMsgAction:(NSString*) action
{
    if ([@"dismiss" isEqualToString:action]) {
        return DISMISS;
    } else if ([@"landing" isEqualToString:action]) {
        return LANDING_PAGE;
    } else if ([@"url" isEqualToString:action]) {
        return URL;
    } else if ([@"deep_link" isEqualToString:action]) {
        return DEEP_LINK;
    }
    
    NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Unexpected InAppMsgAction: %@", action]];
    @throw error;
}



@end
//********************************************************************

//********************************************************************
//InAppMsgText
@interface InAppMsgText : NSObject

@property (nonatomic) NSString* text;
@property (nonatomic) InAppMsgAlign align;
@property (nonatomic) NSString* textColor;

@end

@implementation InAppMsgText
@end
//********************************************************************


//********************************************************************
//InAppMsgButton
@interface InAppMsgButton : InAppMsgText

@property (nonatomic) NSString* selectedBGColor;
@property (nonatomic) NSString* unSelectedBgColor;

@end

@implementation InAppMsgButton
@end
//********************************************************************

//********************************************************************
//InAppMsgCover
@interface InAppMsgCover : NSObject

@property (nonatomic) NSString* url;

@end

@implementation InAppMsgCover
@end
//********************************************************************

//********************************************************************
//InAppMsgClick
@interface InAppMsgClick : NSObject

@property (nonatomic) InAppMsgAction action;
@property (nonatomic) NSString* value;
@property (nonatomic) NSString* track;
@property (nonatomic) NSString* params;

@end

@implementation InAppMsgClick
@end
//********************************************************************


//********************************************************************
//InAppMsgInteractions
@interface InAppMsgInteractions : NSObject

@property (nonatomic) InAppMsgClick* click;
@property (nonatomic) InAppMsgClick* click0;
@property (nonatomic) InAppMsgClick* click1;
@property (nonatomic) InAppMsgClick* dismiss;

@end

@implementation InAppMsgInteractions
@end
//********************************************************************


//********************************************************************
//InAppMsgBody
@interface InAppMsgBody : NSObject

@property (nonatomic) InAppMsgText* header;
@property (nonatomic) InAppMsgCover* cover;
@property (nonatomic) InAppMsgText* title;
@property (nonatomic) InAppMsgText* content;
@property (nonatomic) NSArray<InAppMsgButton* >* footer;

@end

@implementation InAppMsgBody
@end
//********************************************************************


//********************************************************************
//in app message
@interface InAppMessage : NSObject

@property (nonatomic) NSString* ID;
@property (nonatomic) InAppMsgLayoutType type;
@property (nonatomic) InAppMsgBody* body;
@property (nonatomic) InAppMsgInteractions* interactions;
@property (nonatomic) BOOL autoDismiss;
@property (nonatomic) NSString* dismissTimeout;
@property (nonatomic) NSString* displayLimit;
@property (nonatomic) NSString* backgroundColor;
@property (nonatomic) NSString* dismissColor;
@property (nonatomic) BOOL showDismiss;
@property (nonatomic) InAppMsgAlign position;
@property (nonatomic) BOOL floatingButtons;

@end

@implementation InAppMessage

- (BOOL)isEqual:(InAppMessage *)object {
    if (object != NULL && [self.ID isEqual:object.ID]) {
        return YES;
    }
    
    return NO;
}


- (NSUInteger)hash {
    return [self.ID hash];
}

@end
//********************************************************************












