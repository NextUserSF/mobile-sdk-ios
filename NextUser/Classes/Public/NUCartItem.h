#import <Foundation/Foundation.h>
#import "NUJSONObject.h"

@interface NUCartItem : NUJSONObject

+ (instancetype)cartItemWithName:(NSString *)name andID:(NSString *) ID;

@property (nonatomic) NSString *ID;
@property (nonatomic) double quantity;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *category;
@property (nonatomic) double price;
@property (nonatomic) NSString *desc;

@end
