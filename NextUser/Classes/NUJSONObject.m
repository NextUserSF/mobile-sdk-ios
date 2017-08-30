//
//  NUJSONObject.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUJSONObject.h"

@implementation NUJSONObject

- (NSDictionary *) dictionaryReflectFromAttributes
{
    @autoreleasepool
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        unsigned int count = 0;
        objc_property_t *attributes = class_copyPropertyList([self class], &count);
        objc_property_t property;
        NSString *key, *value;
        
        for (int i = 0; i < count; i++)
        {
            property = attributes[i];
            key = [NSString stringWithUTF8String:property_getName(property)];
            value = [self valueForKey:key];
            
            id val;
            if ([value isKindOfClass:[NUJSONObject class]]) {
                val = (NUJSONObject*) value;
                val = [val dictionaryReflectFromAttributes];
            } else if ([value isKindOfClass:[NSArray<NUJSONObject*> class]]) {
                NSArray<NUJSONObject*>* valArray = (NSArray<NUJSONObject*>*) value;
                NSMutableArray* val = [NSMutableArray arrayWithCapacity:[valArray count]];
                for (NUJSONObject* v in valArray) {
                    [val addObject: [v dictionaryReflectFromAttributes]];
                }
            } else {
                val = value;
            }
            
            
            [dict setObject:(val ? val : @"") forKey:key];
        }
        
        free(attributes);
        attributes = nil;
        
        return dict;
    }
}

@end
