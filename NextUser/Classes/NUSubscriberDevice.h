//
//  NUSubscriberDevice.h
//  NextUser
//
//  Created by Adrian Lazea on 27/09/2017.
//

#import <Foundation/Foundation.h>

@interface NUSubscriberDevice : NSObject

@property (nonatomic) NSString *os;
@property (nonatomic) NSString *osVersion;
@property (nonatomic) NSString *deviceModel;
@property (nonatomic) NSString *resolution;
@property (nonatomic) NSString *trackingSource;
@property (nonatomic) NSString *trackingVersion;
@property (nonatomic) BOOL mobile;
@property (nonatomic) BOOL tablet;

@end
