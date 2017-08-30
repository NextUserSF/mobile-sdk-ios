//
//  NUInAppMsgUIManager.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInAppMsgUIManager.h"
#import "NextUserManager.h"
#import "NUInAppMessageWrapperBuilder.h"

@interface InAppMsgUIManager()
{
    NSOperationQueue* queue;
    InAppMsgViewSettings* viewSettings;
}

@end


@implementation InAppMsgUIManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];
        [queue setName:@"com.nextuser.iamsDisplayQueue"];
        viewSettings = [[InAppMsgViewSettings alloc] init];
    }
    
    return self;
}

-(void) sendToQueue:(NSString*) iamID
{
    NSOperation* operation = [self createIamDisplayOperation:iamID];
    [queue addOperation:operation];
}

-(InAppMsgViewSettings*) viewSettings
{
    return viewSettings;
}


-(NSOperation*) createIamDisplayOperation:(NSString*) iamID
{
    return [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(displayOperationSelector:) object:iamID];
}

-(void)displayOperationSelector:(NSString*) iamID
{
    InAppMessage* message = [[[NextUserManager sharedInstance] inAppMsgCacheManager] fetchMessage:iamID];
    if (message != nil) {
        InAppMsgWrapper* wrapper = [InAppMessageWrapperBuilder toWrapper:message];
        if (wrapper != nil) {
            //dispatch_group_t iamDisplayGroup = dispatch_group_create();
            //dispatch_group_enter(iamDisplayGroup);
            
            //show iam and call dispatch_group_leave(iamDisplayGroup); on dismiss callback
            
            //dispatch_group_wait(iamDisplayGroup, DISPATCH_TIME_FOREVER);
        }
    }
}

@end
