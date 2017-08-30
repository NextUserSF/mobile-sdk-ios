//
//  NUInAppMsgBody.h
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInAppMsgButton.h"
#import "NUInAppMsgCover.h"
#import "NUJSONObject.h"

@interface InAppMsgBody : NUJSONObject

@property (nonatomic) InAppMsgText* header;
@property (nonatomic) InAppMsgCover* cover;
@property (nonatomic) InAppMsgText* title;
@property (nonatomic) InAppMsgText* content;
@property (nonatomic) NSArray<InAppMsgButton* >* footer;

@end
