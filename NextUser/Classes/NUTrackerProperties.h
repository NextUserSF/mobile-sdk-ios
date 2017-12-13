#import <Foundation/Foundation.h>

@interface NUTrackerProperties : NSObject

@property (nonatomic, readonly) NSString *wid;
@property (nonatomic, readonly) NSString *api_key;
@property (nonatomic, readonly) BOOL production_release;
@property (nonatomic, readonly) NSString *log_level;
@property (nonatomic, readonly) BOOL useGeneratedKey;
@property (nonatomic, readonly) BOOL valid;

+ (instancetype)properties;

- (NSString *)apiKey;
- (BOOL)validProps;

@end
