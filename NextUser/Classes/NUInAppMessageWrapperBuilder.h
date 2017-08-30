//
//  NUInAppMessageWrapperBuilder.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//
#import <Foundation/Foundation.h>
#import "NUInAppMsgWrapper.h"

@interface InAppMessageWrapperBuilder : NSObject

+(InAppMsgWrapper*) toWrapper:(InAppMessage* ) message;

@end
