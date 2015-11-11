//
//  NUTracker.h
//  NextUserKit
//
//  Created by Dino on 11/6/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUTracker : NSObject

+ (NUTracker *)sharedTracker;

@property (nonatomic, readonly) BOOL isReady;

@end
