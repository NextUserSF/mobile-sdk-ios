#import <Foundation/Foundation.h>
#import "NUJSONObject.h"

@implementation NUJSONObject

- (NSMutableDictionary *) dictionaryReflectFromAttributes
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
            } else if ([value isKindOfClass:[NSArray class]]) {
                NSArray *valArray = (NSArray *) value;
                if ([self.class array:valArray containsType:[NUJSONObject class]]) {
                    NSArray<NUJSONObject*>* valArray = (NSArray<NUJSONObject*>*) value;
                    val = [NSMutableArray arrayWithCapacity:[valArray count]];
                    for (NUJSONObject* v in valArray)
                    {
                        [val addObject: [v dictionaryReflectFromAttributes]];
                    }
                } else {
                    val = value;
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

+ (BOOL) array:(NSArray *) array containsType:(Class) clazz
{
    NSPredicate *p = [NSPredicate predicateWithFormat:@"self != nil && self isKindOfClass: %@", clazz];
    NSArray *filtered = [array filteredArrayUsingPredicate:p];
    
    return filtered.count == array.count;
}
@end
