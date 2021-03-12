#import <Foundation/Foundation.h>
#import "NUInAppMsgViewSettings.h"

@implementation InAppMsgViewSettings


-(instancetype) init
{

    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *rootView = [[[UIApplication sharedApplication] keyWindow]
                                rootViewController].view;
            CGRect originalFrame = [[UIScreen mainScreen] bounds];
            self->_screenFrame = [rootView convertRect:originalFrame fromView:nil];
            
            self->_statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
            self->_screenHeight = self->_screenFrame.size.height;
            self->_screenWidth  = self->_screenFrame.size.width;
            self->_frameMargin = 25;
            self->_smallMargin = 10;
            self->_largeMargin = 15;
            self->_closeIconHeight = 20;
            self->_fullTextPadding = 17;
            self->_modalTextPadding = 15;
            self->_skinnyTextPadding = 13;
            self->_imagePadding = 10;
            self->_cornerRadius = 6;
            self->_cornerRadiusSmall = 6;
            
            self->_skinnyHeight = (self->_screenHeight - self->_statusBarHeight)/6;
            self->_skinnyWidth = self->_screenWidth;
            self->_skinnyTopMarginTop = self->_statusBarHeight;
            self->_skinnyViewHeight = self->_skinnyHeight - 2*self->_smallMargin;
            self->_skinnyLargeImgWidth = self->_skinnyWidth;
            self->_skinnySmallImgWidth = self->_skinnyWidth/3 - 3*self->_smallMargin;
            
            
            self->_modalHeight = (self->_screenHeight - self->_statusBarHeight)*6/10;
            self->_modalWidth = self->_skinnyWidth - 2*self->_frameMargin;
            self->_modalViewWidth = self->_modalWidth - (2*self->_largeMargin);
            self->_modalMediumViewHeight = self->_modalHeight/2 - self->_largeMargin*3/2;
            
            self->_fullSmallImageHeight = (self->_screenHeight - self->_statusBarHeight)/2;
            self->_fullViewWidth = self->_skinnyWidth - (2*self->_frameMargin);
            
            self->_headerTitleFontSize = 22*72/96;
            self->_contentTitleFontSize = 20*72/96;
            self->_contentBodyFontSize = 17*72/96;
        });
    }
    
    return self;
}

@end
