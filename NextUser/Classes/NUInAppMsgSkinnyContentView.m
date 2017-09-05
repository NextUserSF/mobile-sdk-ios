//
//  NUInAppMsgSkinnyContentView.m
//  Pods
//
//  Created by Adrian Lazea on 31/08/2017.
//
//

#import "NUInAppMsgSkinnyContentView.h"
#import "NextUserManager.h"

@implementation InAppMsgSkinnyContentView : InAppMsgContentView

//override
-(NUPopUpLayout) createLayout
{
    return NUPopUpLayoutMakeWithMargins(NUPopUpHorizontalLayoutCenter,
                                        wrapper.message.position == TOP ? NUPopUpVerticalLayoutTop : NUPopUpVerticalLayoutBottom,
                                        NUPopUpContentMarginsMake(wrapper.message.position == TOP ? settings.skinnyTopMarginTop : 0, 0, 0, 0));
}

- (void) setupMainContainer
{
    [constraints addObject: [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:settings.skinnyHeight]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:settings.skinnyWidth]];
    if ([wrapper isSingleImage] == YES) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTapper:)];
        [self addGestureRecognizer:singleTap];
    }
}

- (void) setupMainContainerWithMargins
{
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeTop multiplier:1.0 constant:settings.smallMargin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self
                                                               attribute:NSLayoutAttributeLeading multiplier:1.0 constant:settings.smallMargin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-settings.smallMargin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant: [wrapper isSingleImage] ? -settings.smallMargin : -settings.smallMargin/2]];
}

- (void) setupHeaderContainer
{
    [super setupHeaderContainer];
    if ([wrapper dismiss] == YES) {
        [super setupHeaderDismissImg];
        headerCloseImgView.image = [[[NextUserManager sharedInstance] inAppMsgImageManager]
                                                                    scaleImage:[UIImage imageNamed:@"chevron_right.png"] toSize:CGSizeMake(settings.closeIconHeight, settings.closeIconHeight)];
        
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerCloseImgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerCloseImgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:settings.closeIconHeight]];
    }
}

- (void) setupCoverContainer
{
    [super setupCoverContainer];
    
    CGFloat imgWidth=0.0;
    if (wrapper.image == YES && wrapper.title == NO && wrapper.content == NO) {
        [coverImgView setContentMode:UIViewContentModeScaleAspectFit];
        imgWidth = settings.skinnyWidth;
    } else {
        [coverImgView setContentMode:UIViewContentModeScaleAspectFill];
        imgWidth = settings.skinnySmallImgWidth;
    }
    
    coverImgView.layer.cornerRadius = 5.0;

    [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imgWidth]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
}

- (void) setupContentContainer
{
    if (wrapper.title == NO && wrapper.content == NO) {
        return;
    }
    
    [super setupContentContainer];
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-settings.smallMargin/2]];
    
    if (wrapper.image == YES) {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:coverImgView attribute:NSLayoutAttributeRight multiplier:1.0 constant:settings.smallMargin]];
    } else {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeLeft multiplier:1.0 constant: 0.0]];
    }
    

    [super setupTitle];
    [super setupContentText];
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTitleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTitleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTitleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentTitleView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:settings.skinnyTextPadding]];
}

@end

