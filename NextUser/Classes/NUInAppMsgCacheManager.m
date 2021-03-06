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

@interface InAppMsgCacheManager()
{
    InAppMessage* pendingMessage;
    NUCache* nuCache;
    NSLock* CACHE_LOCK;
    NSLock* PENDING_IAM_LOCK;
}
- (NSMutableArray<InAppMessage* >*) internalFetchMessages;
- (void) internalCacheMessages:(NSMutableArray<InAppMessage* >*) messages;

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
        CACHE_LOCK = [[NSLock alloc] init];
        PENDING_IAM_LOCK = [[NSLock alloc] init];
        nuCache = cache;
        [self clearAll];
    }
    
    return self;
}

- (InAppMessage* ) fetchMessage:(NSString *) iamID
{
    if ([CACHE_LOCK tryLock]) {
        @try {
            NSArray<InAppMessage* >* localMessages = [self internalFetchMessages];
            if (localMessages == nil || [localMessages count] == 0) {
                return nil;
            }
            
            for(InAppMessage* msg in localMessages) {
                if ([msg.ID isEqual:iamID]) {
                    return msg;
                }
            }
        } @catch (NSException *exception) {
            DDLogError(@"Exception on fetchMessage %@", [exception reason]);
        } @finally {
            [CACHE_LOCK unlock];
        }
    }
    
    return nil;
}

- (void) clearAll
{
    [nuCache deleteFile:IAMS_JSON_FILE];
}

- (void) cacheMessages:(NSMutableArray<InAppMessage* >*) messages
{
    if ([CACHE_LOCK tryLock]) {
        @try {
            NSMutableArray<InAppMessage* >* localMessages = [self internalFetchMessages];
            if (localMessages != nil && [localMessages count] > 0) {
                [localMessages addObjectsFromArray:messages];
            } else {
                localMessages = messages;
            }
            [self internalCacheMessages:localMessages];
            
        } @catch (NSException *exception) {
            DDLogError(@"Exception on cacheMessages %@", [exception reason]);
        } @finally {
            [CACHE_LOCK unlock];
        }
    }
}

- (void) cacheMessage:(InAppMessage* ) message
{
    if ([CACHE_LOCK tryLock]) {
        @try {
            NSMutableArray<InAppMessage* >* localMessages = [self internalFetchMessages];
            if (localMessages == nil && [localMessages count] == 0) {
                localMessages = [[NSMutableArray alloc] init];
            }
            
            if ([localMessages containsObject:message]) {
                [localMessages removeObject:message];
            }
            
            [localMessages addObject:message];
            [self internalCacheMessages:localMessages];
            
        } @catch (NSException *exception) {
            DDLogError(@"Exception on cacheMessage %@", [exception reason]);
        } @finally {
            [CACHE_LOCK unlock];
        }
    }
}


- (void) updateMessage:(InAppMessage* ) message withRemoval:(BOOL) remove
{
    if ([CACHE_LOCK tryLock]) {
        @try {
            NSMutableArray<InAppMessage* >* localMessages = [self internalFetchMessages];
            if (localMessages != nil && [localMessages count] > 0 && [localMessages containsObject:message]) {
                [localMessages removeObject:message];
                if (remove == NO)
                {
                     [localMessages addObject:message];
                }
                [self internalCacheMessages:localMessages];
            }
        } @catch (NSException *exception) {
            DDLogError(@"Exception on cacheMessage %@", [exception reason]);
        } @finally {
            [CACHE_LOCK unlock];
        }
    }
}


- (void) setPendingMessage:(InAppMessage* ) message
{
    if ([PENDING_IAM_LOCK tryLock]) {
        @try {
            pendingMessage = message;
        } @catch (NSException *exception) {
            DDLogError(@"Exception on setPendingMessage %@", [exception reason]);
        } @finally {
            [PENDING_IAM_LOCK unlock];
        }
    }
}


- (InAppMessage* ) getPendingMessage
{
    if ([PENDING_IAM_LOCK tryLock]) {
        @try {
            return pendingMessage;
        } @catch (NSException *exception) {
            DDLogError(@"Exception on setPendingMessage %@", [exception reason]);
        } @finally {
            [PENDING_IAM_LOCK unlock];
        }
    }
}


- (void) clearPendingMessage
{
    if ([PENDING_IAM_LOCK tryLock]) {
        @try {
            int displayLimit = [pendingMessage.displayLimit intValue];
            if (displayLimit >= 0) {
                BOOL remove = displayLimit == 0;
                if (remove == YES) {
                    //[[[NextUserManager sharedInstance] getWorkflowManager] removeWorkflow:pendingMessage.ID];
                } else {
                    displayLimit = displayLimit - 1;
                    pendingMessage.displayLimit = [NSString stringWithFormat:@"%d",displayLimit];
                }
                
                [self updateMessage:pendingMessage withRemoval:remove];
            }
            
            pendingMessage = nil;
        } @catch (NSException *exception) {
            DDLogError(@"Exception on setPendingMessage %@", [exception reason]);
        } @finally {
            [PENDING_IAM_LOCK unlock];
        }
    }
}

- (void) internalCacheMessages:(NSArray<InAppMessage* >*) messages
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
    }
}

- (NSMutableArray<InAppMessage* >*) internalFetchMessages
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

    
    return nil;
}

@end
