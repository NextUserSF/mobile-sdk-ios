//
//  NUInAppMsgInteractions.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInAppMsgClick.h"
#import "NUJSONObject.h"

@interface InAppMsgInteractions : NUJSONObject

@property (nonatomic) InAppMsgClick* click;
@property (nonatomic) InAppMsgClick* click0;
@property (nonatomic) InAppMsgClick* click1;
@property (nonatomic) InAppMsgClick* dismiss;
@property (nonatomic) NSString* nuTrackingParams;

@end
