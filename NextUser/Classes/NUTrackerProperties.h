#import <Foundation/Foundation.h>


@interface NUTrackerProperties : NSObject

+ (instancetype)properties;

- (NSString *)apiKey;
- (BOOL)validProps;

@property (nonatomic, readonly) NSString *devApiKey;
@property (nonatomic, readonly) NSString *prodApiKey;
@property (nonatomic, readonly) NSString *wid;
@property (nonatomic, readonly) int devLogLevel;
@property (nonatomic, readonly) int prodLogLevel;
@property (nonatomic, readonly) BOOL isProduction;
@property (nonatomic, readonly) BOOL useGeneratedKey;
@property (nonatomic, readonly) BOOL valid;

@end
