#import <Foundation/Foundation.h>

@interface NUDeviceToken : NSObject

@property (nonatomic) NSString *deviceOS;
@property (nonatomic) NSString *token;
@property (nonatomic) NSString *provider;
@property (nonatomic) BOOL active;

@end
