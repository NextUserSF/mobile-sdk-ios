#import <Foundation/Foundation.h>
#import "NUInAppMsgCacheManager.h"
#import "NUDDLog.h"
#import "NUJSONTransformer.h"
#import "NextUserManager.h"

#define IAMS_JSON_FILE @"in_app_messages.json"
#define IAMS_SHA_JSON_FILE @"in_app_messages_sha.json"

@interface InAppMsgCacheManager()
{
    NUCache* nuCache;
    NSObject *IAM_CACHE_LOCK;
    NSObject *SHA_CACHE_LOCK;
}

- (void) internalCacheMessages:(NSMutableArray<InAppMessage* >*) messages;
- (void) internalCacheShaList:(NSMutableArray<NSString* >*) shaList;
- (NSMutableArray<InAppMessage* >*) fetchMessages;

@end

@implementation InAppMsgCacheManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        IAM_CACHE_LOCK = [[NSObject alloc] init];
        SHA_CACHE_LOCK = [[NSObject alloc] init];
        nuCache = [[NUCache alloc] init];
    }
    
    return self;
}

- (NSString *) getNextMessageID
{
    @synchronized (IAM_CACHE_LOCK) {
        NSArray<InAppMessage* >* localMessages = [self fetchMessages];
        if (localMessages != nil && [localMessages count] > 0)
        {
            return [[localMessages firstObject] ID];
        }
        
        return nil;
    }
}

- (InAppMessage* ) fetchMessage:(NSString *) iamID
{
    @synchronized (IAM_CACHE_LOCK) {
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
}

- (void) clearFile:(NSString *) fileName
{
    [nuCache deleteFile:fileName];
}

- (void) cacheMessages:(NSMutableArray<InAppMessage* >*) messages
{
    @synchronized (IAM_CACHE_LOCK) {
        NSMutableArray<InAppMessage* >* localMessages = [self fetchMessages];
        if (localMessages != nil && [localMessages count] > 0) {
            [localMessages addObjectsFromArray:messages];
        } else {
            localMessages = messages;
        }
        [self internalCacheMessages:localMessages];
    }
}

- (void) cacheMessage:(InAppMessage* ) message
{
    @synchronized (IAM_CACHE_LOCK) {
        NSMutableArray<InAppMessage* >* localMessages = [self fetchMessages];
        if (localMessages == nil || [localMessages count] == 0) {
            localMessages = [[NSMutableArray alloc] init];
        }
        
        if ([localMessages containsObject:message]) {
            
            return;
        }
        
        [localMessages addObject:message];
        [self internalCacheMessages:localMessages];
    }
}

- (void) onMessageDismissed:(NSString* ) messageID
{
    @synchronized (IAM_CACHE_LOCK) {
        @try
        {
            NSMutableArray<InAppMessage* >* localMessages = [self fetchMessages];
            InAppMessage *removeMsg = nil;
            for(InAppMessage *nextMsg in localMessages)
            {
                if ([nextMsg ID] == messageID) {
                    int displayLimit = [nextMsg.displayLimit intValue] - 1;
                    if (displayLimit <= 0) {
                        removeMsg = nextMsg;
                    } else {
                        nextMsg.displayLimit = [NSString stringWithFormat:@"%d",displayLimit];
                    }
                    break;
                }
            }
            
            if (removeMsg != nil) {
                [localMessages removeObject:removeMsg];
            }
            
            [self internalCacheMessages:localMessages];
        } @catch (NSException *exception) {
            DDLogError(@"Exception on onMessageDismissed %@", [exception reason]);
        } @catch (NUError *error) {
            DDLogError(@"Error on onMessageDismissed %@", error);
        }
    }
}

- (NSMutableArray<NSString* >*) fetchShaList
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
    }
}
- (NSString *) getNextSHAKey
{
    @synchronized (SHA_CACHE_LOCK) {
        NSMutableArray<NSString* >* shaList = [self fetchShaList];
        if (shaList != nil && [shaList count] > 0)
        {
            return [shaList firstObject];
        }
        
        return nil;
    }
}

- (void) removeSha:(NSString *) sha
{
    @synchronized (SHA_CACHE_LOCK) {
        NSMutableArray<NSString* >* shaList = [self fetchShaList];
        if (shaList != nil && [shaList count] > 0 && [shaList containsObject: sha] == YES) {
            [shaList removeObject: sha];
            [self internalCacheShaList: shaList];
        }
    }
}

- (void) addNewSha:(NSString *) sha;
{
    @synchronized (SHA_CACHE_LOCK) {
        NSMutableArray<NSString* >* shaList = [self fetchShaList];
        if (shaList == nil) {
            shaList = [[NSMutableArray alloc] init];
        }
        
        if ([shaList containsObject: sha] == NO) {
            [shaList addObject: sha];
            [self internalCacheShaList: shaList];
        }
    }
}

- (NSMutableArray<InAppMessage* >*) fetchMessages
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
    }
}

- (void) internalCacheMessages:(NSArray<InAppMessage* >*) messages
{
    @try
    {
        if (messages == nil || [messages count] == 0) {
            [self clearFile:IAMS_JSON_FILE];
            
            return;
        }
        
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
    }
}

- (void) internalCacheShaList:(NSMutableArray<NSString* >*) shaList
{
    @try
    {
        if (shaList == nil || [shaList count] == 0) {
            [self clearFile:IAMS_SHA_JSON_FILE];
            
            return;
        }
        
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
    }
}

@end
