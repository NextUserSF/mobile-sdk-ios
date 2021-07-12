//
//  NUJSExport.h
//  Pods
//
//  Created by Adrian Lazea on 06.07.2021.
//

#import <Foundation/Foundation.h>
#import "NUEvent.h"
#import "NUConstants.h"

@protocol NUWebViewContainerListener <NSObject>
- (void) onClose;
@end

typedef NS_ENUM(NSUInteger, NUUrlAuthority) {
    CLOSE_AUTHORITY = 0,
    RELOAD_AUTHORITY,
    CUSTOM_LINK_AUTHORITY,
    SOCIAL_SHARE_AUTHORITY,
    CUSTOM_EVENT_AUTHORITY,
    UNKNOWN_AUTHORITY
};

@interface NUWebViewHelper:NSObject
+(NUUrlAuthority) toNUUrlAuthority:(NSString*) authority;
+(NSMutableDictionary *) getQueryDictionary:(NSURL*) url;
+(NUEvent *) buildEventFromQueryDictionary:(NSDictionary *) query;
+(id) extractParameterFromQueryDictionary:(NSDictionary *) query forKey:(NSString *) key;
@end
