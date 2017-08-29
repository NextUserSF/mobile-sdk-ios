//
//  NUCache.h
//  Pods
//
//  Created by Adrian Lazea on 29/08/2017.
//
//
#import <Foundation/Foundation.h>
#import "NSString+LGUtils.h"

@interface NUCache : NSObject

- (void) createFile:(NSString* ) fileName;
- (BOOL) containsFile:(NSString* ) fileName;
- (void) clearCache;
- (void) deleteFile:(NSString* ) fileName;
- (void) writeData:(NSData* ) data toFile:(NSString*) fileName;
- (NSData* ) readFromFile:(NSString* ) fileName;

@end
