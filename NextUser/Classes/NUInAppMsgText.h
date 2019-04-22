#import <Foundation/Foundation.h>
#import "NUInAppMessageEnumTransformer.h"
#import "NUJSONObject.h"

@interface InAppMsgText : NUJSONObject

@property (nonatomic) NSString* text;
@property (nonatomic) InAppMsgAlign align;
@property (nonatomic) NSString* textColor;
@property (nonatomic) CGFloat textSize;

@end
