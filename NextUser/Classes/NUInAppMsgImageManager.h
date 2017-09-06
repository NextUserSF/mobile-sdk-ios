
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
- (UIImage *) getImageResource:(NSString *) imageName;
- (UIImage *) scaleImage:(UIImage *)imageToResize toSize:(CGSize)theNewSize;
- (UIImage *) scaleImageResource:(NSString *)imageName toSize:(CGSize)theNewSize;
- (UIImage *) fetchImageSync:(NSString* )url toSize:(CGSize)theNewSize;

@end



