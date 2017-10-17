//
//  NUTrackerProperties.m
//  Pods
//
//  Created by Adrian Lazea on 10/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUTrackerProperties.h"
#import "NUObjectPropertyStatusUtils.h"
#import "NSString+LGUtils.h"
#import "NUDDLog.h"

#define kDevApiKey @"development_api_key"
#define kProdApiKey @"production_api_key"
#define kProdMode @"production_mode"
#define kDevLogLvl @"development_log_level"
#define kProdLogLvl @"production_log_level"
#define kWidKey @"wid"


@implementation NUTrackerProperties

+ (instancetype)properties
{
    return [[NUTrackerProperties alloc] init];
}

- (id)init
{
    if (self = [super init]) {
        NSData *plistData;
        NSError *error;
        NSPropertyListFormat format;
        id plist;
        
        NSString *localizedPath = [[NSBundle mainBundle] pathForResource:@"nextuser" ofType:@"plist"];
        plistData = [NSData dataWithContentsOfFile:localizedPath];
        plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
        if (!plist) {
            DDLogError(@"Error reading plist. %@", error);
            _valid = NO;
        } else {
            NSDictionary *props = (NSDictionary *)plist;
            _devApiKey       = props[kDevApiKey];
            _prodApiKey      = props[kProdApiKey];
            _isProduction    = [[props objectForKey:kProdMode] boolValue];
            _devLogLevel     = props[kDevLogLvl];
            _prodLogLevel    = props[kProdLogLvl];
            _wid             = props[kWidKey];
            _useGeneratedKey = NO;
            _valid           = YES;
        }
    }
    
    return self;
}

- (NSString *)apiKey
{
    if (!_useGeneratedKey) {
        return _wid;
    }
    
    if (_isProduction) {
        return _prodApiKey;
    }
    
    return _devApiKey;
}

- (BOOL)validProps
{
    return _valid;
}

@end
