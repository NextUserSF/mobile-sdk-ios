//
//  NUPubNubManager.m
//  NextUserKit
//
//  Created by Dino on 2/9/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUPubNubClient.h"
#import "NUTrackerSession.h"
#import "PubNub.h"
#import "NUPushMessage.h"
#import "NUIAMUITheme.h"

@interface NUPubNubClient () <PNObjectEventListener>

@property (nonatomic) PubNub *client;

@end

@implementation NUPubNubClient

- (id)initWithSession:(NUTrackerSession *)session
{
    if (self = [super initWithSession:session]) {
        
        [PNLog enabled:NO];
        
        NSString *publishKey = session.pubNubConfiguration.publishKey;
        NSString *subscribeKey = session.pubNubConfiguration.subscribeKey;
        
        PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:publishKey
                                                                         subscribeKey:subscribeKey];
        self.client = [PubNub clientWithConfiguration:configuration];
        [self.client addListener:self];
        
    }
    
    return self;
}

#pragma mark - Override (Subclass category)

- (void)startListening
{
    NSString *publicChannel = self.session.pubNubConfiguration.publicChannel;
    NSString *privateChannel = self.session.pubNubConfiguration.privateChannel;
    
    [self.client subscribeToChannels:@[publicChannel, privateChannel] withPresence:NO];
}

- (void)stopListening
{
    [self.client unsubscribeFromAll];
}

- (void)fetchMissedMessages
{
    [self.client historyForChannel:@"my_channel" start:nil end:nil limit:100
                    withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
                        
                        // Check whether request successfully completed or not.
                        if (!status.isError) {
                            
                            // Handle downloaded history using:
                            //   result.data.start - oldest message time stamp in response
                            //   result.data.end - newest message time stamp in response
                            //   result.data.messages - list of messages
                        }
                        // Request processing failed.
                        else {
                            
                            // Handle message history download error. Check 'category' property to find
                            // out possible issue because of which request did fail.
                            //
                            // Request can be resent using: [status retry];
                        }
                    }];
}

#pragma mark - Private

- (void)onMessageReceived:(id)message
{
    NUPushMessage *pushMessage = [self.class pushMessageFromPubNubMessageContent:message];
    [self.delegate pushMessageService:self didReceiveMessages:@[pushMessage]];
}

+ (NUPushMessage *)pushMessageFromPubNubMessageContent:(id)messageContent
{
    NUPushMessage *message = [[NUPushMessage alloc] init];
    
    // message text
    message.messageText = messageContent[@"message_text"];
    
    // message content
    message.contentURL = [NSURL URLWithString:messageContent[@"content_url"]];
    
    // fire date
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    message.fireDate = fireDate;

    // IAM UI Theme
    // TODO: parse color codes from message content
    UIColor *backgroundColor = nil;
    UIColor *textColor = nil;
    UIFont *textFont = nil;
    NUIAMUITheme *UITheme = [NUIAMUITheme themeWithBackgroundColor:backgroundColor
                                                         textColor:textColor
                                                          textFont:textFont];
    message.UITheme = UITheme;
    
    return message;
}

#pragma mark - Object Event Listener

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    NSLog(@"Did receive message:");
    NSLog(@"%@", message.data.message);
    NSLog(@"Subscribed channel: %@", message.data.subscribedChannel);
    NSLog(@"Actual channel:     %@", message.data.actualChannel);
    
    id messageContent = message.data.message;
    if (messageContent) {
        [self onMessageReceived:messageContent];
    }
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
    
    NSLog(@"Did receive status: %@", status.stringifiedCategory);
    
    /* UNSUBSCRIBE
    if (status.category == PNUnexpectedDisconnectCategory) {
        // This event happens when radio / connectivity is lost
    }
    
    else if (status.category == PNConnectedCategory) {
        
        // Connect event. You can do stuff like publish, and know you'll get it.
        // Or just use the connected event to confirm you are subscribed for
        // UI / internal notifications, etc
        
    }
    else if (status.category == PNReconnectedCategory) {
        
        // Happens as part of our regular operation. This event happens when
        // radio / connectivity is lost, then regained.
    }
    else if (status.category == PNDecryptionErrorCategory) {
        
        // Handle messsage decryption error. Probably client configured to
        // encrypt messages and on live data feed it received plain text.
    }
     */
    
    if (status.category == PNUnexpectedDisconnectCategory) {
        // This event happens when radio / connectivity is lost
    }
    
    else if (status.category == PNConnectedCategory) {
        
        // Connect event. You can do stuff like publish, and know you'll get it.
        // Or just use the connected event to confirm you are subscribed for
        // UI / internal notifications, etc
        
//        [self.client publish: @"Hello from the PubNub Objective-C SDK" toChannel:@"my_channel"
//              withCompletion:^(PNPublishStatus *status) {
//                  
//                  // Check whether request successfully completed or not.
//                  if (!status.isError) {
//                      
//                      // Message successfully published to specified channel.
//                  }
//                  // Request processing failed.
//                  else {
//                      
//                      // Handle message publish error. Check 'category' property to find out possible issue
//                      // because of which request did fail.
//                      //
//                      // Request can be resent using: [status retry];
//                  }
//              }];
    }
    else if (status.category == PNReconnectedCategory) {
        
        // Happens as part of our regular operation. This event happens when
        // radio / connectivity is lost, then regained.
    }
    else if (status.category == PNDecryptionErrorCategory) {
        
        // Handle messsage decryption error. Probably client configured to
        // encrypt messages and on live data feed it received plain text.
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event
{
    NSLog(@"Presence event");
}

@end
