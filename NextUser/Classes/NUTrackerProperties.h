#import <Foundation/Foundation.h>


@interface NUTrackerProperties : NSObject

@property (nonatomic, readonly) NSString *wid;
@property (nonatomic, readonly) NSString *api_key;
@property (nonatomic, readonly) BOOL production_release;
@property (nonatomic, readonly) NSString *devLogLevel;
@property (nonatomic, readonly) NSString *prodLogLevel;
@property (nonatomic, readonly) BOOL useGeneratedKey;
@property (nonatomic, readonly) BOOL valid;

+ (instancetype)properties;

- (NSString *)apiKey;
- (BOOL)validProps;

@end
