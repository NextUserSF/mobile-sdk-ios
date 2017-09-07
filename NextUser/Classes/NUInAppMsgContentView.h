//
//  NUInAppMsgContentView.h
//  Pods
//
//  Created by Adrian Lazea on 31/08/2017.
//
//


#import <Foundation/Foundation.h>
#import "NUInAppMsgWrapper.h"
#import "NUInAppMsgViewSettings.h"
#import "NUInAppMessageUIView.h"
#import "NUUIButton.h"

@interface InAppMsgContentView : UIView
{
    InAppMsgWrapper *wrapper;
    InAppMsgViewSettings *settings;
    
    NSMutableArray<NSLayoutConstraint *> *constraints;
    
    //main frame with margins
    UIView *layoutWithMarginsView;
    
    //header
    UIView *headerView;
    UILabel *headerTitle;
    UIImageView *headerCloseImgView;
    
    //cover
    UIImageView *coverImgView;
    
    //content
    UIView *contentView;
    UILabel *contentTitleView;
    UILabel *contentTextView;
    
    //footer
    UIView *footerView;
    NUUIButton *button0;
    NUUIButton *button1;
    
    //mainLayout
    NUPopUpLayout mainLayout;
}

-(instancetype)initWithWrapper:(InAppMsgWrapper *) messageWrapper withSettings:(InAppMsgViewSettings *) viewSettings;
- (void)dismissTapper:(id)sender;
- (void)nuButton0Pressed:(id)sender;
- (void)nuButton1Pressed:(id)sender;
- (NUPopUpLayout) getLayout;


#pragma mark Subclassing
- (NUPopUpLayout) createLayout;
- (void) setupMainContainer;
- (void) setupMainContainerWithMargins;
- (void) setupHeaderContainer;
- (void) setupHeaderTitle;
- (void) setupHeaderDismissImg;
- (void) setupCoverContainer;
- (void) setupContentContainer;
- (void) setupTitle;
- (void) setupContentText;
- (void) setupFooterContainer;
- (BOOL) isBorderView;

@end

