//
//  NUWebViewHelper.m
//  AFNetworking
//
//  Created by Adrian Lazea on 06.07.2021.
//

#import <Foundation/Foundation.h>
#import "NUWebViewHelper.h"

@implementation NUWebViewHelper:NSObject

+(NUUrlAuthority) toNUUrlAuthority:(NSString*) authority
{
    if ([NU_URL_AUTHORITY_CLOSE isEqualToString:authority]) {
        
        return CLOSE_AUTHORITY;
    } else if ([NU_URL_AUTHORITY_RELOAD isEqualToString:authority]) {
        
        return RELOAD_AUTHORITY;
    }
        
    return UNKNOWN_AUTHORITY;
}

+(NSMutableDictionary *) getQueryDictionary:(NSURL*) url {
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableDictionary *queryStrings = [[NSMutableDictionary alloc] init];
    for (NSURLQueryItem *queryItem in [urlComponents queryItems]) {
        if (queryItem.value == nil) {
            continue;
        }
        [queryStrings setObject:queryItem.value forKey:queryItem.name];
    }
    
    return queryStrings;
}

+(NUEvent *) buildEventFromQueryDictionary:(NSDictionary *) query
{
    NSString * eventString = [NUWebViewHelper extractParameterFromQueryDictionary: query forKey:NU_PARAM_NAME_EVENT];
    if (eventString == nil) {
        
        return nil;
    }
    NSMutableArray *parameters = [NUWebViewHelper extractParameterFromQueryDictionary: query forKey:NU_PARAM_NAME_PARAMETERS];
    
    return [NUEvent eventWithName:eventString andParameters:parameters];
}

+(id) extractParameterFromQueryDictionary:(NSDictionary *) query forKey:(NSString *) key
{
    if (query == nil) {
        
        return nil;
    }
    
    return [query valueForKey:key];
}

@end
