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
    message.backgroundColor = [messageJSON objectForKey:@"dismissColor"];
    message.showDismiss = [[messageJSON objectForKey:@"showDismiss"] boolValue];
    message.floatingButtons = [[messageJSON objectForKey:@"floatingButtons"] boolValue];
    message.position = [InAppMessageEnumTransformer toInAppMsgAlign: [messageJSON objectForKey:@"position"]];
    
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
        return object;
    }
    
    InAppMsgText* inAppMsgTxt = nil;
    inAppMsgTxt = [[InAppMsgText alloc] init];
    inAppMsgTxt.text = [object objectForKey:@"text"];
    inAppMsgTxt.align = [InAppMessageEnumTransformer toInAppMsgAlign: [object objectForKey:@"align"]];
    inAppMsgTxt.textColor = [object objectForKey:@"textColor"];

    return inAppMsgTxt;
}

+ (InAppMsgCover*) convertToInMessageCover:(id) object
{
    if (object == nil || [object isKindOfClass:[NSString class]]) {
        return object;
    }
    
    InAppMsgCover* inAppMsgCover = nil;
    inAppMsgCover = [[InAppMsgCover alloc] init];
    inAppMsgCover.url = [object objectForKey:@"url"];
    
    return inAppMsgCover;
}

+ (InAppMsgButton*) convertToInMessageButton:(id) object
{
    if (object == nil || [object isKindOfClass:[NSString class]]) {
        return object;
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

+ (NSMutableArray<Workflow* >*) toWorkflows:(id) workflowsJSONArray
{
    NSMutableArray<Workflow* >* workFlows;
    if (workflowsJSONArray != nil && [workflowsJSONArray isKindOfClass:[NSArray class]])
    {
        Workflow* workflow;
        workFlows = [[NSMutableArray alloc] init];
        for(id object in workflowsJSONArray)
        {
            if (object == nil || [object isKindOfClass:[NSString class]]) {
                continue;
            }
            
            workflow = [[Workflow alloc] init];
            workflow.ID = [object objectForKey:@"id"];
            workflow.iamID = [object objectForKey:@"iamId"];
            
            if ([[object objectForKey:@"conditions"] isKindOfClass:[NSArray class]])
            {
                WorkflowCondition* condition;
                id conditionsObject = [object objectForKey:@"conditions"];
                if (conditionsObject == nil || [conditionsObject isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                NSMutableArray<WorkflowCondition *> * wkConditions = [NSMutableArray arrayWithCapacity:[conditionsObject count]];
                for(id condObject in conditionsObject)
                {
                    condition = [[WorkflowCondition alloc] init];
                    condition.rule = [WorkflowEnumTransformer toWorkflowRule: [condObject objectForKey:@"rule"]];
                    condition.value = [condObject objectForKey:@"value"];
                    [wkConditions addObject:condition];
                }
                workflow.conditions = wkConditions;
            }
            
            [workFlows addObject:workflow];
        }
    }
    
    return workFlows;
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
