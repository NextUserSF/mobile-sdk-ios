#import <Foundation/Foundation.h>
#import "NUCache.h"
#import <UIKit/UIKit.h>

@interface InAppMsgImageManager: NSObject

- (UIImage *) getImageResource:(NSString *) imageName;
- (UIImage *) scaleImage:(UIImage *)imageToResize toSize:(CGSize)theNewSize;
- (UIImage *) scaleImageResource:(NSString *)imageName toSize:(CGSize)theNewSize;
- (UIImage *) fetchImageSync:(NSString* )url toSize:(CGSize)theNewSize;

@end



