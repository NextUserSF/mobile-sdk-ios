#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface NUJSONObject : NSObject

- (NSMutableDictionary *) dictionaryReflectFromAttributes;

@end
