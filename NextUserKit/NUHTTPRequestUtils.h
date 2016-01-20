//
//  NUHTTPRequestUtils.h
//  NextUserKit
//
//  Created by Dino on 11/25/15.
//  Copyright © 2015 NextUser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUHTTPRequestUtils : NSObject

+ (void)sendGETRequestWithPath:(NSString *)path
                    parameters:(NSDictionary *)parameters
                    completion:(void(^)(id responseObject, NSError *error))completion;

@end
