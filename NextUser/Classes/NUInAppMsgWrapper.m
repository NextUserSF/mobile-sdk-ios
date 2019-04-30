#import <Foundation/Foundation.h>
#import "NUInAppMsgWrapper.h"
#import "NSString+LGUtils.h"

@implementation InAppMsgWrapper

+ (instancetype) initWithMessage:(InAppMessage*) message
{
    InAppMsgWrapper* instance = [[InAppMsgWrapper alloc] initWithMessage:message];
    
    return instance;
}

-(instancetype) initWithMessage:(InAppMessage*) message
{
    
    self = [super init];
    if (self) {
        if (message == nil) {
            return self;
        }
        
        InAppMsgBody* body = message.body;
        if (body == nil) {
            NSError* error = [NUError nextUserErrorWithMessage:
                              [NSString stringWithFormat:@"Invalid In app message - no body detected...: %@", message.ID]];
            @throw error;
        }
        
        _message      = message;
        _image        = body.cover != nil && [NSString lg_isEmptyString:body.cover.url] == NO;
        _content      = body.content != nil && [NSString lg_isEmptyString:body.content.text] == NO;
        _contentHTML  = body.contentHTML != nil && [NSString lg_isEmptyString:body.contentHTML.html] == NO;
        _title        = body.title != nil && [NSString lg_isEmptyString:body.title.text] == NO;
        _headerText   = body.header != nil && [NSString lg_isEmptyString:body.header.text] == NO;
        _dismiss      = message.showDismiss == YES;
        _footer       = body.footer != nil && [body.footer count] > 0;
        _interactions = message.interactions != nil;
        
        if (_contentHTML == NO && _image == NO && (_content == NO || _title == NO)) {
            NSError* error = [NUError nextUserErrorWithMessage:
                              [NSString stringWithFormat:@"Invalid in app message configuration: %@", message.ID]];
            @throw error;
        }
    }
    
    return self;
}

- (BOOL) isSingleImage
{
    return _image && _headerText == NO && _content == NO && _title == NO && _footer == NO;
}
- (BOOL) hasBody
{
    return _content == YES || _title == YES;
}

- (BOOL) containsHeader
{
    return _headerText == YES || _dismiss == YES;
}

- (BOOL) isContentHTML
{
    return _contentHTML;
}

- (InAppMsgText* ) getHeader
{
    return _message.body.header;
}

- (InAppMsgText* ) getContent
{
    return _message.body.content;
}

- (InAppMsgText* ) getTitle
{
    return _message.body.title;
}
- (InAppMsgCover* ) getCover
{
    return _message.body.cover;
}

- (NSArray<InAppMsgButton *>* ) getFooterItems
{
    return _message.body.footer;
}

- (InAppMsgInteractions*) getInAppMsgInteractions
{
    if (_interactions == NO) {
        return nil;
    }
    
    return _message.interactions;
}

- (InAppMsgClick* ) getDefaultClickConfiguration
{
    if (_interactions == NO) {
        return nil;
    }
    
    return [[self getInAppMsgInteractions] click];
}


- (InAppMsgClick* ) getClick0Configuration
{
    if (_interactions == NO) {
        return nil;
    }
    
    return [[self getInAppMsgInteractions] click0] != nil ? [[self getInAppMsgInteractions] click0] : [self getDefaultClickConfiguration];
}

- (InAppMsgClick* ) getClick1Configuration
{
    if (_interactions == NO) {
        return nil;
    }
    
    return [[self getInAppMsgInteractions] click1] != nil ? [[self getInAppMsgInteractions] click1] : [self getDefaultClickConfiguration];
}

- (InAppMsgClick* ) getDismissClickConfiguration
{
    if (_interactions == NO) {
        return nil;
    }
    
    return [[self getInAppMsgInteractions] dismiss];
}

- (BOOL) isImageAndFloatingFooter
{
    return [self isSingleImage] == YES ||
    (_image == YES && [self hasBody] == NO && _headerText == NO && _footer == YES && _message.floatingButtons == YES);
}

@end
