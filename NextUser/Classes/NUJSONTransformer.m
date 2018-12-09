//
//  NUJSONTransformer.m
//  Pods
//
//  Created by Adrian Lazea on 29/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUJSONTransformer.h"
#import "NUDDLog.h"
#import "NSString+LGUtils.h"
#import "NUEvent.h"

@implementation NUJSONTransformer

+ (InAppMessage* ) toInAppMessage:(id) messageJSON
{
    if (messageJSON == nil) {
        return nil;
    }
    
    InAppMessage* message = [[InAppMessage alloc] init];
    
    message.ID = [messageJSON objectForKey:@"id"] ? [messageJSON objectForKey:@"id"] : [messageJSON objectForKey:@"ID"];
    message.type = [InAppMessageEnumTransformer toInAppMsgType: [messageJSON objectForKey:@"type"]];
    message.autoDismiss = [[messageJSON objectForKey:@"autoDismiss"] boolValue];
    message.dismissTimeout = [messageJSON objectForKey:@"dismissTimeout"];
    message.backgroundColor = [messageJSON objectForKey:@"backgroundColor"];
    message.dismissColor = [messageJSON objectForKey:@"dismissColor"];
    message.showDismiss = [[messageJSON objectForKey:@"showDismiss"] boolValue];
    message.floatingButtons = [[messageJSON objectForKey:@"floatingButtons"] boolValue];
    message.position = [InAppMessageEnumTransformer toInAppMsgAlign: [messageJSON objectForKey:@"position"]];
    message.displayLimit = [messageJSON objectForKey:@"displayLimit"];
    
    
    id bodyObject = [messageJSON objectForKey:@"body"];
    if (bodyObject != nil) {
        message.body = [[InAppMsgBody alloc] init];
        message.body.header = [self convertToInMessageText: [bodyObject objectForKey:@"header"]];
        message.body.title = [self convertToInMessageText: [bodyObject objectForKey:@"title"]];
        message.body.content = [self convertToInMessageText: [bodyObject objectForKey:@"content"]];
        message.body.cover = [self convertToInMessageCover: [bodyObject objectForKey:@"cover"]];
        
        NSArray* footerObjArray;
        if ([[bodyObject objectForKey:@"footer"] isKindOfClass:[NSArray class]])
        {
            footerObjArray = [bodyObject objectForKey:@"footer"];
            NSMutableArray<InAppMsgButton*> * footer = [NSMutableArray arrayWithCapacity:[footerObjArray count]];
            for (id fObj in footerObjArray) {
                [footer addObject:[self convertToInMessageButton:fObj]];
            }
            message.body.footer = footer;
        }
    }
    
    id interactionsObject = [messageJSON objectForKey:@"interactions"];
    if (interactionsObject != nil) {
        message.interactions = [[InAppMsgInteractions alloc] init];
        message.interactions.click = [self convertToInMessageClick: [interactionsObject objectForKey:@"click"]];
        message.interactions.click0 = [self convertToInMessageClick: [interactionsObject objectForKey:@"click0"]];
        message.interactions.click1 = [self convertToInMessageClick: [interactionsObject objectForKey:@"click1"]];
        message.interactions.dismiss = [self convertToInMessageClick: [interactionsObject objectForKey:@"dismiss"]];
        message.interactions.nuTrackingParams = [interactionsObject objectForKey:@"nuTrackingParams"];
    }
    
    
    return message;
}

+ (NSMutableArray<InAppMessage* >*) toInAppMessages:(id) messagesJSONArray
{
    NSMutableArray<InAppMessage* >* messages;
    if (messagesJSONArray != nil && [messagesJSONArray isKindOfClass:[NSArray class]])
    {
        messages = [[NSMutableArray alloc] init];
        for(id messageJSON in messagesJSONArray)
        {
            [messages addObject:[self toInAppMessage:messageJSON]];
        }
    }
    
    return messages;
}


+ (InAppMsgText*) convertToInMessageText:(id) object
{
    if (object == nil || [object isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    InAppMsgText* inAppMsgTxt = nil;
    inAppMsgTxt = [[InAppMsgText alloc] init];
    inAppMsgTxt.text = [object objectForKey:@"text"];
    inAppMsgTxt.align = [InAppMessageEnumTransformer toInAppMsgAlign: [object objectForKey:@"align"]];
    inAppMsgTxt.textColor = [object objectForKey:@"textColor"];

    return inAppMsgTxt;
}

+ (InAppMsgClick*) convertToInMessageClick:(id) object
{
    if (object == nil || [object isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    InAppMsgClick* inAppMsgClick = nil;
    inAppMsgClick = [[InAppMsgClick alloc] init];
    inAppMsgClick.action = [InAppMessageEnumTransformer toInAppMsgAction:[object objectForKey:@"action"]];
    inAppMsgClick.value = [object objectForKey:@"value"];
    
    id trackEventsArrObj = [object objectForKey:@"trackEvents"];
    if (trackEventsArrObj != nil && [trackEventsArrObj isKindOfClass:[NSArray class]]) {
        NSMutableArray<NUEvent* >* trackEventsArr = [[NSMutableArray alloc] init];
        for(id eventJSON in trackEventsArrObj)
        {
            NUEvent *event = nil;
            id parametersJSONString = [eventJSON objectForKey:@"parameters"];
            if (parametersJSONString != nil)
            {
                NSArray *parametersArr = [parametersJSONString componentsSeparatedByString:@","];
                event = [NUEvent eventWithName: [eventJSON objectForKey:@"eventName"] andParameters:[NSMutableArray arrayWithArray:parametersArr]];
            } else
            {
                event = [NUEvent eventWithName: [eventJSON objectForKey:@"eventName"]];
            }
            [trackEventsArr addObject:event];
        }
    }
    
    return inAppMsgClick;
}

+ (InAppMsgCover*) convertToInMessageCover:(id) object
{
    if (object == nil || [object isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    InAppMsgCover* inAppMsgCover = nil;
    inAppMsgCover = [[InAppMsgCover alloc] init];
    inAppMsgCover.url = [object objectForKey:@"url"];
    
    return inAppMsgCover;
}

+ (InAppMsgButton*) convertToInMessageButton:(id) object
{
    if (object == nil || [object isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    InAppMsgButton* inAppMsgBtn = nil;
    inAppMsgBtn = [[InAppMsgButton alloc] init];
    inAppMsgBtn.text = [object objectForKey:@"text"];
    inAppMsgBtn.align = [InAppMessageEnumTransformer toInAppMsgAlign: [object objectForKey:@"align"]];
    inAppMsgBtn.textColor = [object objectForKey:@"textColor"];
    inAppMsgBtn.selectedBGColor = [object objectForKey:@"selectedBGColor"];
    inAppMsgBtn.unSelectedBgColor = [object objectForKey:@"unSelectedBgColor"];
    
    return inAppMsgBtn;
}

+ (id) toInAppMessagesJSON:(NSArray<InAppMessage* >*) messages
{
    if (messages == nil || [messages count] == 0) {
        return nil;
    }
    
    NSMutableArray* messagesJSON = [NSMutableArray arrayWithCapacity:[messages count]];
    for (InAppMessage* msg in messages) {
        [messagesJSON addObject:[self toInAppMessageJSON:msg]];
    }
    
    return messagesJSON;
}

+ (id) toInAppMessageJSON:(InAppMessage* ) message
{
    if (message == nil) {
        return nil;
    }
    
    return [message dictionaryReflectFromAttributes];
}

@end
