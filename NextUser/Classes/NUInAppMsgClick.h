//
//  NUInAppMsgClick.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//


#import <Foundation/Foundation.h>
#import "NUInAppMessageEnumTransformer.h"

@interface InAppMsgClick : NSObject

@property (nonatomic) InAppMsgAction action;
@property (nonatomic) NSString* value;
@property (nonatomic) NSString* track;
@property (nonatomic) NSString* params;

@end
