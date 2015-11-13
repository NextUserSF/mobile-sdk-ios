//
//  NUTracker+Tests.h
//  NextUserKit
//
//  Created by Dino on 11/13/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <NextUserKit/NextUserKit.h>

@interface NUTracker (Tests)

- (void)trackScreenWithName:(NSString *)screenName completion:(void(^)(NSError *error))completion;

@end
