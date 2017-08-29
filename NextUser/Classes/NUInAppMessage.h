//
//  NUInAppMessage.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//
#import <Foundation/Foundation.h>
#import "NUInAppMsgBody.h"
#import "NUInAppMsgInteractions.h"

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
