#import "NUInAppMsgImageManager.h"
#import "NSString+LGUtils.h"


@implementation InAppMsgImageManager
{
    NUCache* nuCache;
    NSBundle *bundle;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        nuCache = [[NUCache alloc] init];
        bundle = [NSBundle bundleForClass:[self class]];
    }
    
    return self;
}

- (UIImage *)fetchImageSync:(NSString* )url toSize:(CGSize)theNewSize
{
    @try {
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
    } @catch(NSException *e) {
        
        return nil;
    }@catch(NSError *e) {
        
        return nil;
    }
}

-(UIImage*) getImageResource:(NSString *) imageName
{
    return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
}

- (UIImage *)scaleImageResource:(NSString *)imageName toSize:(CGSize)theNewSize
{
    return [self scaleImage:[self getImageResource:imageName] toSize:theNewSize];
}

- (UIImage *)scaleImage:(UIImage *)imageToResize toSize:(CGSize)theNewSize {
    
    if (imageToResize == nil) {
        return nil;
    }
    
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
