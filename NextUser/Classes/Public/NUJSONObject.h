#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NUJSONObject : NSObject

- (NSMutableDictionary *) dictionaryReflectFromAttributes;

@end
