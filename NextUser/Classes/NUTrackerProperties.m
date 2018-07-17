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

#define kWidKey @"wid"
#define kApiKey @"api_key"
#define kLogLvl @"log_level"
#define kProductionRelease @"production_release"

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
            _wid = props[kWidKey];
            _api_key       = props[kApiKey];
            _production_release = YES;
            _log_level       = props[kLogLvl];
            _useGeneratedKey = NO;
            _valid           = YES;
            _notifications   = YES;
        }
    }
    
    return self;
}

- (NSString *)apiKey
{
    if (_useGeneratedKey == NO) {
        return _wid;
    }
    
    return _api_key;
}

- (BOOL)validProps
{
    return _valid;
}

@end
