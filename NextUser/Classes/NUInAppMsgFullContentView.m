//
//  NUInAppMsgModalContentView.m
//  Pods
//
//  Created by Adrian Lazea on 06/09/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInAppMsgFullContentView.h"
#import "NextUserManager.h"
#import "UIColor+CreateMethods.h"
#import "NUInAppMsgViewHelper.h"

@interface InAppMsgFullContentView()
{
    UIView* borderView;
}
@end

@implementation InAppMsgFullContentView : InAppMsgContentView


-(NUPopUpLayout) createLayout
{
    return NUPopUpLayoutMakeWithMargins(NUPopUpHorizontalLayoutCenter,
                                        NUPopUpVerticalLayoutCenter,
                                        NUPopUpContentMarginsMake(settings.statusBarHeight,
                                                                  0, 0, 0));}

- (void) setupMainContainer
{
    [constraints addObject: [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:settings.screenHeight]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:settings.screenWidth]];
}

- (void) setupMainContainerWithMargins
{
    [self addSubview:layoutWithMarginsView];
    
    CGFloat margin = [wrapper isImageAndFloatingFooter] == YES ? 0.0 : settings.frameMargin;
    CGFloat negativeMarginRight = margin != 0.0 ? -margin : 0.0;
    CGFloat negativeMarginBottom = margin != 0.0 ? -margin - settings.statusBarHeight : 0.0;
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeTop multiplier:1.0 constant:margin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeLeft multiplier:1.0 constant:margin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeBottom multiplier:1.0 constant: negativeMarginBottom]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeRight multiplier:1.0 constant: negativeMarginRight]];
}

- (void) setupHeaderContainer
{
    if ([wrapper isImageAndFloatingFooter] == YES) {
        return;
    }
    
    if (wrapper.headerText == YES || wrapper.dismiss == YES) {
        [super setupHeaderContainer];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        
        if (wrapper.headerText == YES) {
            [super setupHeaderTitle];
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerTitle attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerTitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerTitle attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
            
            if (wrapper.dismiss == NO) {
                [constraints addObject: [NSLayoutConstraint constraintWithItem:headerTitle attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
            }
        }
        
        if (wrapper.dismiss == YES) {
            [super setupHeaderDismissImg];
            [headerView addSubview:headerCloseImgView];
            [headerCloseImgView setImage: [[[NextUserManager sharedInstance] inAppMsgImageManager]
                                           scaleImageResource:@"cancel.png" toSize:CGSizeMake(settings.closeIconHeight, settings.closeIconHeight)]];
            
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerCloseImgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerCloseImgView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerCloseImgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
            
            if (wrapper.headerText == YES) {
                [constraints addObject: [NSLayoutConstraint constraintWithItem:headerCloseImgView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:headerTitle
                                                                     attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:settings.largeMargin]];
            }
        }
        
        if (wrapper.image == YES) {
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:coverImgView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-settings.largeMargin]];
        } else if (wrapper.content == YES) {
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-settings.largeMargin]];
        } else if (wrapper.footer == YES) {
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-settings.largeMargin]];
        } else {
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        }
    }
}

- (void) setupCoverContainer
{
    if (wrapper.image == NO) {
        return;
    }
    
    [super setupCoverContainer];
    if ([wrapper isImageAndFloatingFooter] == YES) {
        [coverImgView setContentMode:UIViewContentModeScaleAspectFill];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:settings.screenWidth]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom multiplier:1 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        
        if (wrapper.dismiss == YES) {
            [super setupHeaderDismissImg];
            [layoutWithMarginsView addSubview:headerCloseImgView];
            [headerCloseImgView setImage: [[[NextUserManager sharedInstance] inAppMsgImageManager]
                                           scaleImageResource:@"cancel.png" toSize:CGSizeMake(settings.closeIconHeight, settings.closeIconHeight)]];
            
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerCloseImgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:settings.largeMargin]];
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerCloseImgView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-settings.largeMargin]];
        }
        
    } else {
        [coverImgView setContentMode:UIViewContentModeScaleAspectFill];
        [coverImgView.layer setCornerRadius: settings.cornerRadius];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:settings.fullViewWidth]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:settings.fullSmallImageHeight]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    }
    
    if (wrapper.headerText == NO && wrapper.dismiss == NO) {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    }
    
    if ([wrapper hasBody] == YES) {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-settings.largeMargin]];
    }
}

- (void) setupContentContainer
{
    if (wrapper.title == NO && wrapper.content == NO) {
        return;
    }
    
    [super setupContentContainer];
    
    
    if (wrapper.title == YES) {
        [super setupTitle];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTitleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant: 0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTitleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant: 0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTitleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:
                                 NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        
        if (wrapper.content == NO) {
            [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTitleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:
                                     NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        }
    }
    
     if (wrapper.content == YES) {
         [super setupContentText];
         [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
         [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
          [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
         
         if (wrapper.title == YES) {
             [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentTitleView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:settings.fullTextPadding]];
         } else {
             [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
         }
     }
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    
    
    if (wrapper.image == NO && wrapper.headerText == NO) {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    }
}

- (void) setupFooterContainer
{
    if (wrapper.footer == NO) {
        return;
    }
    
    [super setupFooterContainer];
    [button0 setContentEdgeInsets: UIEdgeInsetsMake(10, 20, 10, 20)];
    
    CGFloat margin = [wrapper isImageAndFloatingFooter] == NO ? 0.0 : settings.frameMargin;
    CGFloat negativeMarginRight= margin != 0.0 ? -margin : 0.0;
    CGFloat negativeMarginBottom = margin != 0.0 ? -margin - settings.statusBarHeight : 0.0;
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:negativeMarginBottom]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:margin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeRight multiplier:1.0 constant:negativeMarginRight]];
    
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:button0 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:button0 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:button0 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    if([[wrapper getFooterItems] count] > 1 ) {
        [button1 setContentEdgeInsets: UIEdgeInsetsMake(10, 20, 10, 20)];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:button0 attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:settings.largeMargin]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:button0 attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    } else {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:button0 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:settings.fullViewWidth/2]];
    }
}

- (BOOL) isBorderView
{
    return NO;
}

@end
