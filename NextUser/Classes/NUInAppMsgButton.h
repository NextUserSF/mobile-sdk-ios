#import <Foundation/Foundation.h>
#import "NUInAppMsgText.h"

@interface InAppMsgButton : NUJSONObject

@property (nonatomic) NSString* text;
@property (nonatomic) InAppMsgAlign align;
@property (nonatomic) NSString* textColor;
@property (nonatomic) NSString* selectedBGColor;
@property (nonatomic) NSString* unSelectedBgColor;
@property (nonatomic) CGFloat textSize;

@end
