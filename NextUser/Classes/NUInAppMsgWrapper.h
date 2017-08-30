//
//  NUInAppMsgWrapper.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInAppMessage.h"


@interface InAppMsgWrapper : NSObject

@property(nonatomic) InAppMessage* message;
@property(nonatomic) UIImage* messageImage;
@property(nonatomic) BOOL image;
@property(nonatomic) BOOL content;
@property(nonatomic) BOOL title;
@property(nonatomic) BOOL headerText;
@property(nonatomic) BOOL dismiss;
@property(nonatomic) BOOL footer;
@property(nonatomic) BOOL interactions;
@property(nonatomic) CGSize imageSize;

+ (instancetype) initWithMessage:(InAppMessage*) message;

- (BOOL) isSingleImage;
- (BOOL) hasBody;
- (BOOL) containsHeader;
- (InAppMsgText* ) getHeader;
- (InAppMsgText* ) getContent;
- (InAppMsgText* ) getTitle;
- (InAppMsgCover* ) getCover;
- (NSArray<InAppMsgButton *>* ) getFooterItems;
- (InAppMsgInteractions*) getInAppMsgInteractions;
- (InAppMsgClick* ) getDefaultClickConfiguration;
- (InAppMsgClick* ) getClick0Configuration;
- (InAppMsgClick* ) getClick1Configuration;
- (InAppMsgClick* ) getDismissClickConfiguration;

@end
