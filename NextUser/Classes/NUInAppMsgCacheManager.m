////
////  NUInAppMsgCacheManager.m
////  Pods
////
////  Created by Adrian Lazea on 29/08/2017.
////
////
//
#import <Foundation/Foundation.h>
#import "NUInAppMsgCacheManager.h"
#import "NUDDLog.h"
#import "NUJSONTransformer.h"
#import "NextUserManager.h"

#define IAMS_JSON_FILE @"in_app_messages.json"
#define IAMS_SHA_JSON_FILE @"in_app_messages_sha.json"

@interface InAppMsgCacheManager()
{
    InAppMessage* pendingMessage;
    NUCache* nuCache;
    NSLock* IAM_CACHE_LOCK;
    NSLock* SHA_CACHE_LOCK;
}

- (void) internalCacheMessages:(NSMutableArray<InAppMessage* >*) messages;
- (void) internalCacheShaList:(NSMutableArray<NSString* >*) shaList;

@end


@implementation InAppMsgCacheManager

+ (instancetype)initWithCache:(NUCache*) cache
{
    InAppMsgCacheManager* instance = [[InAppMsgCacheManager alloc] init: cache];
    
    return instance;
}

- (instancetype)init:(NUCache*)cache
{
    self = [super init];
    if (self) {
        IAM_CACHE_LOCK = [[NSLock alloc] init];
        SHA_CACHE_LOCK = [[NSLock alloc] init];
        nuCache = cache;
    }
    
    return self;
}

- (InAppMessage* ) fetchMessage:(NSString *) iamID
{
    NSArray<InAppMessage* >* localMessages = [self fetchMessages];
    if (localMessages == nil || [localMessages count] == 0) {
        return nil;
    }
    
    for (InAppMessage* msg in localMessages) {
        if ([msg.ID isEqual:iamID])
        {
            return msg;
        }
    }
    
    return nil;
}

- (void) clearAll
{
    [nuCache deleteFile:IAMS_JSON_FILE];
    [nuCache deleteFile:IAMS_SHA_JSON_FILE];
}

- (void) cacheMessages:(NSMutableArray<InAppMessage* >*) messages
{
    NSMutableArray<InAppMessage* >* localMessages = [self fetchMessages];
    if (localMessages != nil && [localMessages count] > 0) {
        [localMessages addObjectsFromArray:messages];
    } else {
        localMessages = messages;
    }
    [self internalCacheMessages:localMessages];
}

- (void) cacheMessage:(InAppMessage* ) message
{
    NSMutableArray<InAppMessage* >* localMessages = [self fetchMessages];
    if (localMessages == nil || [localMessages count] == 0) {
        localMessages = [[NSMutableArray alloc] init];
    }
    
    if ([localMessages containsObject:message]) {
        [localMessages removeObject:message];
    }
    
    [localMessages addObject:message];
    [self internalCacheMessages:localMessages];
}


- (void) updateMessage:(InAppMessage* ) message withRemoval:(BOOL) remove
{
    NSMutableArray<InAppMessage* >* localMessages = [self fetchMessages];
    if (localMessages != nil && [localMessages count] > 0 && [localMessages containsObject:message]) {
        [localMessages removeObject:message];
        if (remove == NO)
        {
            [localMessages addObject:message];
        }
        [self internalCacheMessages:localMessages];
    }
}


- (void) setPendingMessage:(InAppMessage* ) message
{
    if ([IAM_CACHE_LOCK tryLock]) {
        @try {
            pendingMessage = message;
        } @catch (NSException *exception) {
            DDLogError(@"Exception on setPendingMessage %@", [exception reason]);
        } @finally {
            [IAM_CACHE_LOCK unlock];
        }
    }
}


- (InAppMessage* ) getPendingMessage
{
    if ([IAM_CACHE_LOCK tryLock]) {
        @try {
            return pendingMessage;
        } @catch (NSException *exception) {
            DDLogError(@"Exception on setPendingMessage %@", [exception reason]);
        } @finally {
            [IAM_CACHE_LOCK unlock];
        }
    }
}


- (void) clearPendingMessage
{
    if ([IAM_CACHE_LOCK tryLock]) {
        @try {
            int displayLimit = [pendingMessage.displayLimit intValue];
            if (displayLimit >= 0) {
                BOOL remove = displayLimit == 0;
                if (remove == NO) {
                    displayLimit = displayLimit - 1;
                    pendingMessage.displayLimit = [NSString stringWithFormat:@"%d",displayLimit];
                }
                [self updateMessage:pendingMessage withRemoval:remove];
            }
            
            pendingMessage = nil;
        } @catch (NSException *exception) {
            DDLogError(@"Exception on setPendingMessage %@", [exception reason]);
        } @finally {
            [IAM_CACHE_LOCK unlock];
        }
    }
}

- (void) internalCacheMessages:(NSArray<InAppMessage* >*) messages
{
    if ([IAM_CACHE_LOCK tryLock])
    {
        @try
        {
            NSError *error = nil;
            NSArray* messagesJSONArray = [NUJSONTransformer toInAppMessagesJSON:messages];
            NSData *json = [NSJSONSerialization dataWithJSONObject:messagesJSONArray options:NSJSONWritingPrettyPrinted error:&error];
            if (json != nil && error == nil) {
                [nuCache writeData:json toFile:IAMS_JSON_FILE];
            } else {
                DDLogDebug(@"Exception on json serialization of messages %@", error);
            }
        } @catch (NSException *exception) {
            DDLogError(@"Exception on internalCacheMessages %@", [exception reason]);
        } @catch (NUError *error) {
            DDLogError(@"Error on internalCacheMessages %@", error);
        } @finally {
            [IAM_CACHE_LOCK unlock];
        }
    }
}

- (NSMutableArray<InAppMessage* >*) fetchMessages
{
    if ([IAM_CACHE_LOCK tryLock])
    {
        @try
        {
            NSError *error = nil;
            NSData *jsonData = [nuCache readFromFile:IAMS_JSON_FILE];
            if (jsonData == nil || [jsonData length] == 0) {
                return nil;
            }
            
            id object = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
            if (error != nil) {
                DDLogError(@"Exception on internalFetchMessages on data deserialization %@", error);
                return nil;
            }
            
            return [NUJSONTransformer toInAppMessages:object];
        } @catch (NSException *exception) {
            DDLogError(@"Exception on internalFetchMessages %@", [exception reason]);
        } @catch (NUError *error) {
            DDLogError(@"Error on internalFetchMessages %@", error);
        } @finally {
            [IAM_CACHE_LOCK unlock];
        }
    }
}

- (void) internalCacheShaList:(NSMutableArray<NSString* >*) shaList
{
    if ([SHA_CACHE_LOCK tryLock])
    {
        @try
        {
            NSError *error = nil;
            NSData *json = [NSJSONSerialization dataWithJSONObject:shaList options:NSJSONWritingPrettyPrinted error:&error];
            if (json != nil && error == nil) {
                [nuCache writeData:json toFile:IAMS_SHA_JSON_FILE];
            } else {
                DDLogDebug(@"Exception on json serialization of sha list %@", error);
            }
        } @catch (NSException *exception) {
            DDLogError(@"Exception on internalCacheShaList %@", [exception reason]);
        } @catch (NUError *error) {
            DDLogError(@"Error on internalCacheShaList %@", error);
        } @finally {
            [SHA_CACHE_LOCK unlock];
        }
    }
}

- (NSMutableArray<NSString* >*) fetchShaList
{
    if ([SHA_CACHE_LOCK tryLock])
    {
        @try
        {
            NSError *error = nil;
            NSData *jsonData = [nuCache readFromFile:IAMS_SHA_JSON_FILE];
            if (jsonData == nil || [jsonData length] == 0) {
                
                return nil;
            }
            
            id object = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
            if (error != nil) {
                DDLogError(@"Exception on internalFetchShaList on data deserialization %@", error);
                
                return nil;
            }
            
            if (object != nil && [object isKindOfClass:[NSArray class]])
            {
                NSMutableArray<NSString* >* shaList = [[NSMutableArray alloc] init];
                for(id sha in object)
                {
                    [shaList addObject: sha];
                }
                
                return shaList;
            }
            
            return nil;
        } @catch (NSException *exception) {
            DDLogError(@"Exception on internalFetchShaList %@", [exception reason]);
        } @catch (NUError *error) {
            DDLogError(@"Error on internalFetchShaList %@", error);
        } @finally {
            [SHA_CACHE_LOCK unlock];
        }
    }
}

- (void) removeSha:(NSString *) sha
{
    NSMutableArray<NSString* >* shaList = [self fetchShaList];
    if (shaList != nil && [shaList count] > 0 && [shaList containsObject: sha] == YES) {
        [shaList removeObject: sha];
        [self internalCacheShaList: shaList];
    }
}

- (void) addNewSha:(NSString *) sha;
{
    NSMutableArray<NSString* >* shaList = [self fetchShaList];
    if (shaList == nil) {
        shaList = [[NSMutableArray alloc] init];
    }
    
    if ([shaList containsObject: sha] == NO) {
        [shaList addObject: sha];
        [self internalCacheShaList: shaList];
    }
}

@end
