#import <Foundation/Foundation.h>
#import "NUInAppMsgButton.h"
#import "NUInAppMsgCover.h"
#import "NUInAppMsgContentHtml.h"
#import "NUJSONObject.h"

@interface InAppMsgBody : NUJSONObject

@property (nonatomic) InAppMsgText* header;
@property (nonatomic) InAppMsgCover* cover;
@property (nonatomic) InAppMsgText* title;
@property (nonatomic) InAppMsgText* content;
@property (nonatomic) InAppMsgContentHtml* contentHTML;
@property (nonatomic) NSArray<InAppMsgButton* >* footer;

@end
