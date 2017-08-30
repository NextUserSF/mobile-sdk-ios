//
//  NUInAppMessageWrapperBuilder.m
//  Pods
//
//  Created by Adrian Lazea on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInAppMessageWrapperBuilder.h"
#import "NextUserManager.h"

@implementation InAppMessageWrapperBuilder

+ (InAppMsgWrapper*) toWrapper:(InAppMessage* ) message
{
    InAppMsgWrapper* wrapper = [InAppMsgWrapper initWithMessage: message];
    [self setImageProperties:wrapper];
    if (wrapper.image == YES && wrapper.imageSize.height != 0 && wrapper.imageSize.width != 0) {
        wrapper.messageImage = [[[NextUserManager sharedInstance] inAppMsgImageManager]
                                fetchImageSync:[wrapper getCover].url toSize:wrapper.imageSize];
    }
    
    return wrapper;
}

+ (void) setImageProperties:(InAppMsgWrapper* ) wrapper
{
    if (wrapper.image == NO) {
        return;
    }
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    InAppMsgViewSettings* settings = [[[NextUserManager sharedInstance] inAppMsgUIManager] viewSettings];
    
    switch (wrapper.message.type) {
        case SKINNY:
            width  = [wrapper hasBody] == NO ? settings.skinnyLargeImgWidth : settings.skinnySmallImgWidth;
            height = settings.skinnyViewHeight;
            break;
        case MODAL:
            width  = settings.modalViewWidth;
            height = [wrapper isSingleImage] == YES ? settings.modalHeight : settings.modalMediumViewHeight;
            break;
        case FULL:
            width  = settings.screenWidth;
            height = [wrapper hasBody] == YES ? settings.fullSmallImageHeight : settings.screenHeight;
            break;
        default:
            break;
    }
    
    wrapper.imageSize = CGSizeMake(width, height);
}

@end
