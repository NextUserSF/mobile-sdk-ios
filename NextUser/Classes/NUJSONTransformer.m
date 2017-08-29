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


@implementation NUJSONTransformer

+ (NSMutableArray<InAppMessage* >*) toInAppMessages:(id) messagesJSONArray
{
    NSMutableArray<InAppMessage* >* messages;
    if (messagesJSONArray != nil && [messagesJSONArray isKindOfClass:[NSArray class]])
    {
        InAppMessage* message;
        messages = [[NSMutableArray alloc] init];
        for(id object in messagesJSONArray)
        {
            message = [[InAppMessage alloc] init];
            message.ID = [object objectForKey:@"id"];
            message.type = [InAppMessageEnumTransformer toInAppMsgType: [object objectForKey:@"type"]];
            message.autoDismiss = [[object objectForKey:@"autoDismiss"] boolValue];
            message.dismissTimeout = [object objectForKey:@"dismissTimeout"];
            message.backgroundColor = [object objectForKey:@"backgroundColor"];
            message.backgroundColor = [object objectForKey:@"dismissColor"];
            message.showDismiss = [[object objectForKey:@"showDismiss"] boolValue];
            message.floatingButtons = [[object objectForKey:@"floatingButtons"] boolValue];
            message.position = [InAppMessageEnumTransformer toInAppMsgAlign: [object objectForKey:@"position"]];
            
            id bodyObject = [object objectForKey:@"body"];
            if (bodyObject != nil) {
                message.body = [[InAppMsgBody alloc] init];
                message.body.header = [self convertToInMessageText: [object objectForKey:@"header"]];
                message.body.title = [self convertToInMessageText: [object objectForKey:@"title"]];
                message.body.content = [self convertToInMessageText: [object objectForKey:@"content"]];
                message.body.cover = [self convertToInMessageCover: [object objectForKey:@"cover"]];
                
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
            
            [messages addObject:message];
        }
    }
    
    return messages;
}


+ (InAppMsgText*) convertToInMessageText:(id) object
{
    InAppMsgText* inAppMsgTxt = nil;
    if (object != nil) {
        inAppMsgTxt = [[InAppMsgText alloc] init];
        inAppMsgTxt.text = [object objectForKey:@"text"];
        inAppMsgTxt.align = [InAppMessageEnumTransformer toInAppMsgAlign: [object objectForKey:@"align"]];
        inAppMsgTxt.textColor = [object objectForKey:@"textColor"];
    }
    
    return inAppMsgTxt;
}

+ (InAppMsgCover*) convertToInMessageCover:(id) object
{
    InAppMsgCover* inAppMsgCover = nil;
    if (object != nil) {
        inAppMsgCover = [[InAppMsgCover alloc] init];
        inAppMsgCover.url = [object objectForKey:@"url"];
    }
    
    return inAppMsgCover;
}

+ (InAppMsgButton*) convertToInMessageButton:(id) object
{
    InAppMsgButton* inAppMsgBtn = nil;
    if (object != nil) {
        inAppMsgBtn = [[InAppMsgButton alloc] init];
        inAppMsgBtn.text = [object objectForKey:@"text"];
        inAppMsgBtn.align = [InAppMessageEnumTransformer toInAppMsgAlign: [object objectForKey:@"align"]];
        inAppMsgBtn.textColor = [object objectForKey:@"textColor"];
        inAppMsgBtn.selectedBGColor = [object objectForKey:@"selectedBGColor"];
        inAppMsgBtn.unSelectedBgColor = [object objectForKey:@"unSelectedBgColor"];
    }
    
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
            workflow = [[Workflow alloc] init];
            workflow.ID = [object objectForKey:@"id"];
            workflow.iamID = [object objectForKey:@"iamId"];
            
            if ([[object objectForKey:@"conditions"] isKindOfClass:[NSArray class]])
            {
                WorkflowCondition* condition;
                NSArray* conditions = [object objectForKey:@"conditions"];
                NSMutableArray<WorkflowCondition *> * wkConditions = [NSMutableArray arrayWithCapacity:[conditions count]];
                for(id condObject in conditions)
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

@end
