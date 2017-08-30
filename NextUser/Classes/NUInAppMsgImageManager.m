//
//  NUInAppMsgImageManager.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import "NUInAppMsgImageManager.h"
#import "NSString+LGUtils.h"


@implementation InAppMsgImageManager
{
    NUCache* nuCache;
}

+ (instancetype)initWithCache:(NUCache*) cache
{
    InAppMsgImageManager* instance = [[InAppMsgImageManager alloc] init: cache];
    
    return instance;
}

- (instancetype)init:(NUCache*)cache
{
    self = [super init];
    if (self) {
        nuCache = cache;
    }
    
    return self;
}

- (UIImage *)fetchImageSync:(NSString* )url toSize:(CGSize)theNewSize
{
    NSData * imageData;
    BOOL fileExists = [nuCache containsFile:[url MD5String]] == YES;
    if (fileExists == YES) {
        imageData = [nuCache readFromFile:[url MD5String]];
    } else {
        imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
    }
    
    if (imageData != nil && [imageData length] > 0) {
        if (fileExists == NO) {
            [nuCache writeData:imageData toFile:[url MD5String]];
        }
        return [self scaleImage:[UIImage imageWithData: imageData] toSize:theNewSize];
    }
    
    return nil;
}

- (UIImage *)scaleImage:(UIImage *)imageToResize toSize:(CGSize)theNewSize {
    
    CGFloat width = imageToResize.size.width;
    CGFloat height = imageToResize.size.height;
    float scaleFactor;
    if(width > height) {
        scaleFactor = theNewSize.height / height;
    } else {
        scaleFactor = theNewSize.width / width;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width * scaleFactor, height * scaleFactor), NO, 0.0);
    [imageToResize drawInRect:CGRectMake(0, 0, width * scaleFactor, height * scaleFactor)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end
