
//
//  NUInAppMsgImageManager.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUCache.h"

@interface InAppMsgImageManager: NSObject

+ (instancetype) initWithCache:(NUCache* ) cache;
- (UIImage *)scaleImage:(UIImage *)imageToResize toSize:(CGSize)theNewSize;
- (UIImage *)fetchImageSync:(NSString* )url toSize:(CGSize)theNewSize;

@end



