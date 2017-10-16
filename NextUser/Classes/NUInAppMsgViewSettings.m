//
//  NUInAppMsgViewSettings.m
//  Pods
//
//  Created by Adrian Lazea on 31/08/2017.
//
//

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
            _screenFrame = [rootView convertRect:originalFrame fromView:nil];
            
            _statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
            _screenHeight = _screenFrame.size.height;
            _screenWidth  = _screenFrame.size.width;
            _frameMargin = 25;
            _smallMargin = 10;
            _largeMargin = 15;
            _closeIconHeight = 20;
            _fullTextPadding = 17;
            _modalTextPadding = 15;
            _skinnyTextPadding = 13;
            _imagePadding = 10;
            _cornerRadius = 6;
            _cornerRadiusSmall = 6;
            
            _skinnyHeight = (_screenHeight - _statusBarHeight)/6;
            _skinnyWidth = _screenWidth;
            _skinnyTopMarginTop = _statusBarHeight;
            _skinnyViewHeight = _skinnyHeight - 2*_smallMargin;
            _skinnyLargeImgWidth = _skinnyWidth;
            _skinnySmallImgWidth = _skinnyWidth/3 - 3*_smallMargin;
            
            
            _modalHeight = (_screenHeight - _statusBarHeight)*6/10;
            _modalWidth = _skinnyWidth - 2*_frameMargin;
            _modalViewWidth = _modalWidth - (2*_largeMargin);
            _modalMediumViewHeight = _modalHeight/2 - _largeMargin*3/2;
            
            _fullSmallImageHeight = (_screenHeight - _statusBarHeight)/2;
            _fullViewWidth = _skinnyWidth - (2*_frameMargin);
            
            _headerTitleFontSize = 22*72/96;
            _contentTitleFontSize = 20*72/96;
            _contentBodyFontSize = 17*72/96;
        });
    }
    
    return self;
}

@end
