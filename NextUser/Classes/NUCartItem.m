#import <Foundation/Foundation.h>
#import "NUCartItem.h"

@implementation NUCartItem

+ (instancetype)cartItemWithName:(NSString *)name andID:(NSString *) ID
{
    NUCartItem *item = [[NUCartItem alloc] init];
    item.name = name;
    item.ID = ID;
    item.quantity = 0.0;
    
    return item;
}

- (BOOL)isEqual:(NUCartItem *) object {
    if (object == self)
        return YES;
    
    if (!object || ![object isKindOfClass:[self class]])
        return NO;

    if (![self.ID isEqualToString:object.ID])
        return NO;
    
    return YES;
}

- (NSUInteger)hash {
    
    return [self.ID hash] ^ [self.name hash];
}

@end
