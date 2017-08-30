//
//  NUJSONObject.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NUJSONObject : NSObject

- (NSDictionary *) dictionaryReflectFromAttributes;

@end
