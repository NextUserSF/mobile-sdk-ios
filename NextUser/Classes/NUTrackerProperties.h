#import <Foundation/Foundation.h>


@interface NUTrackerProperties : NSObject

@property (nonatomic, readonly) NSString *devApiKey;
@property (nonatomic, readonly) NSString *prodApiKey;
@property (nonatomic, readonly) NSString *wid;
@property (nonatomic, readonly) int devLogLevel;
@property (nonatomic, readonly) int prodLogLevel;
@property (nonatomic, readonly) BOOL isProduction;
@property (nonatomic, readonly) BOOL useGeneratedKey;
@property (nonatomic, readonly) BOOL valid;

+ (instancetype)properties;

- (NSString *)apiKey;
- (BOOL)validProps;

@end
