//
//  NUFCMManager.m
//  NextUser
//
//  Created by Adrian Lazea on 03/11/2017.
//

#import <Foundation/Foundation.h>
#import "NUFCMManager.h"

@implementation NUFCMManager

// [START refresh_token]
- (void)messaging:(nonnull FIRMessaging *)messaging didRefreshRegistrationToken:(nonnull NSString *)fcmToken
{
    NSLog(@"FCM registration token: %@", fcmToken);
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage
{
    NSLog(@"Received data message: %@", remoteMessage.appData);
}
// [END ios_10_data_message]

@end
