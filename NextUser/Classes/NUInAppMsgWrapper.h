#import <Foundation/Foundation.h>
#import "NUInAppMessage.h"

@protocol InAppMsgInteractionListener <NSObject>
- (void) onInteract:(InAppMsgClick*) clickConfig;
@end

typedef NS_ENUM(NSUInteger, DisplayState) {
    PREPARING = 0,
    READY,
    FAILED
};


@interface InAppMsgWrapper : NSObject

@property(nonatomic) InAppMessage *message;
@property(nonatomic) UIImage *messageImage;
@property(nonatomic) BOOL image;
@property(nonatomic) BOOL content;
@property(nonatomic) BOOL title;
@property(nonatomic) BOOL headerText;
@property(nonatomic) BOOL dismiss;
@property(nonatomic) BOOL footer;
@property(nonatomic) BOOL interactions;
@property(nonatomic) BOOL contentHTML;
@property(nonatomic) CGSize imageSize;
@property(nonatomic) id<InAppMsgInteractionListener> interactionListener;
@property(nonatomic) WKWebView *webView;
@property(nonatomic) DisplayState state;


+ (instancetype) initWithMessage:(InAppMessage*) message;

- (BOOL) isSingleImage;
- (BOOL) hasBody;
- (BOOL) containsHeader;
- (BOOL) isContentHTML;
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
- (BOOL) isImageAndFloatingFooter;

@end
