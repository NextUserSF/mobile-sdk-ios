////
////  NUCache.m
////  Pods
////
////  Created by Adrian Lazea on 29/08/2017.
////
////
//
#import <Foundation/Foundation.h>
#import "NUCache.h"

#define CACHE_DIR @"nu_cache"

@interface NUCache ()
{
    NSString *cacheDir;
    NSLock* WORKFLOWS_LOCK;
    NSFileManager *filemgr;
}

- (NSString* ) formatPathForFileName:(NSString* ) fileName;

@end


@implementation NUCache


-(instancetype)init
{
    self = [super init];
    if (self) {
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        cacheDir = [cachesPath stringByAppendingPathComponent:CACHE_DIR];
        filemgr = [NSFileManager defaultManager];
        if ([filemgr fileExistsAtPath:cacheDir] == NO) {
            NSError *error = nil;
            [filemgr createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:&error];
            if (error) {
                NSLog(@"Error on creating caches dir \"%@\". Error: %@", cacheDir, error);
            }
        }
    }
    
    return self;
}


- (void) createFile:(NSString* ) fileName
{
    [filemgr createFileAtPath: [self formatPathForFileName:fileName] contents: nil attributes: nil];
}


- (BOOL) containsFile:(NSString* ) fileName
{
    return [filemgr fileExistsAtPath:[self formatPathForFileName:fileName]];
}


- (void) clearCache
{
    
}


- (void) deleteFile:(NSString *) fileName
{
    
}


- (void) writeData:(NSData*) data toFile:(NSString*) fileName
{
    [filemgr createFileAtPath:[self formatPathForFileName:fileName] contents: data attributes: nil];
}


- (NSData*) readFromFile:(NSString *) fileName
{
    return [filemgr contentsAtPath:[self formatPathForFileName:fileName]];
}



- (NSString* ) formatPathForFileName:(NSString* ) fileName
{
    return [cacheDir stringByAppendingPathComponent:fileName];
}

@end
