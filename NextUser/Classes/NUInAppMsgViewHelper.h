//
//  NUInAppMsgViewHelper.h
//  Pods
//
//  Created by Adrian Lazea on 31/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInAppMessage.h"

@interface InAppMsgViewHelper : NSObject

+(NSTextAlignment) toTextAlignment:(InAppMsgAlign) align;
+(UIColor*) textColor:(NSString*)hexStr alpha:(CGFloat) alpha;
+(UIColor*) textColor:(NSString*)hexStr;
+(UIColor*) bgColor:(NSString*)hexStr;

@end
