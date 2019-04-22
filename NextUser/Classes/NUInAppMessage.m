#import "NUInAppMessage.h"

@implementation InAppMessage

- (BOOL)isEqual:(InAppMessage *)object {
    if (object != NULL && [self.ID isEqual:object.ID]) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [self.ID hash];
}

@end
