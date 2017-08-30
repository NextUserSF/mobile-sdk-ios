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
        
        UIView *rootView = [[[UIApplication sharedApplication] keyWindow]
                            rootViewController].view;
        CGRect originalFrame = [[UIScreen mainScreen] bounds];
        CGRect adjustedFrame = [rootView convertRect:originalFrame fromView:nil];
        
        _statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        _screenHeight = adjustedFrame.size.height;
        _screenWidth  = adjustedFrame.size.width;
        _frameMargin = 25;
        _smallMargin = 10;
        _largeMargin = 10;
        _closeIconHeight = 20;
        _modalTextPadding = 20;
        _skinnyTextPadding = 20;
        _imagePadding = 10;
        _cornerRadius = 10;
        _cornerRadiusSmall = 6;
        
        _skinnyHeight = (_screenHeight - _statusBarHeight)/6;
        _skinnyWidth = _screenWidth;
        _skinnyTopMarginTop = _statusBarHeight;
        _skinnyViewHeight = _skinnyHeight - 2*_smallMargin;
        _skinnyLargeImgWidth = _skinnyWidth;
        _skinnySmallImgWidth = _skinnyWidth/3 - 3*_smallMargin;
        
        
        _modalHeight = (_screenHeight - _statusBarHeight)*6/10;
        _modalWidth = _skinnyWidth;
        _modalViewWidth = _modalWidth - (2*_largeMargin);
        _modalMediumViewHeight = _modalHeight/2 - _largeMargin*3/2;
        
        _fullSmallImageHeight = (_screenHeight - _statusBarHeight)/2;
    }
    
    return self;
}

@end
