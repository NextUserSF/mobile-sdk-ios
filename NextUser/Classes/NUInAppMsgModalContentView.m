#import <Foundation/Foundation.h>
#import "NUInAppMsgModalContentView.h"
#import "NextUserManager.h"
#import "UIColor+CreateMethods.h"
#import "NUInAppMsgViewHelper.h"

@interface InAppMsgModalContentView()
{
    UIView* borderView;
}
@end

@implementation InAppMsgModalContentView : InAppMsgContentView

//override
-(NUPopUpLayout) createLayout
{
    return NUPopUpLayoutMakeWithMargins(NUPopUpHorizontalLayoutCenter,
                                        NUPopUpVerticalLayoutCenter,
                                        NUPopUpContentMarginsMake(
                                            0, 0, 0, 0));
}

- (void) setupMainContainer
{
    [constraints addObject: [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:settings.modalHeight]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:settings.modalWidth]];
    
    borderView = [[UIView alloc] init];
    [borderView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [borderView setClipsToBounds:YES];
    borderView.backgroundColor = [InAppMsgViewHelper bgColor:wrapper.message.backgroundColor];
    borderView.layer.cornerRadius = settings.cornerRadius;
    [self addSubview:borderView];
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeBottom multiplier:1.0 constant: 0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:borderView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeRight multiplier:1.0 constant: 0.0]];
    
    [borderView addSubview:layoutWithMarginsView];
    
    
    UIColor *frameBorderColor = [UIColor colorWithHex:@"#85929E" alpha:1.0];
    borderView.layer.borderColor = frameBorderColor.CGColor;
    borderView.layer.borderWidth = 1.51f;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = frameBorderColor.CGColor;
    self.layer.shadowOffset = CGSizeMake(4, 4);
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowRadius = 1;
}

- (void) setupMainContainerWithMargins
{
    CGFloat margin = [wrapper isImageAndFloatingFooter] == YES ? 0.0 : settings.largeMargin;
    CGFloat negativeMargin = margin != 0.0 ? -margin : 0.0;
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:borderView
        attribute:NSLayoutAttributeTop multiplier:1.0 constant:margin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:borderView
        attribute:NSLayoutAttributeLeft multiplier:1.0 constant:margin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:borderView
        attribute:NSLayoutAttributeBottom multiplier:1.0 constant: negativeMargin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:borderView
        attribute:NSLayoutAttributeRight multiplier:1.0 constant: negativeMargin]];
}

- (void) setupHeaderContainer
{
    if (wrapper.headerText == YES) {
        [super setupHeaderContainer];
        [super setupHeaderTitle];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        
        
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerTitle attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerTitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerTitle attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:headerTitle attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        
        if (wrapper.image == YES) {
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:coverImgView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-settings.smallMargin]];
        } else if (wrapper.content == YES) {
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-settings.smallMargin]];
        } else if (wrapper.footer == YES) {
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-settings.smallMargin]];
        } else {
            [constraints addObject: [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        }
    }

    if (wrapper.dismiss == NO) {
        return;
    }
    
    [super setupHeaderDismissImg];
    [self addSubview:headerCloseImgView];
    [headerCloseImgView setImage: [[[NextUserManager sharedInstance] inAppMsgImageManager]
                                   scaleImageResource:@"cancel.png" toSize:CGSizeMake(settings.closeIconHeight, settings.closeIconHeight)]];
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:headerCloseImgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:headerCloseImgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0.0]];
    
}

- (void) setupCoverContainer
{
    if (wrapper.image == NO) {
        return;
    }
    
    [super setupCoverContainer];
    if ([wrapper isImageAndFloatingFooter] == YES) {
        [coverImgView setContentMode:UIViewContentModeScaleAspectFill];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:settings.modalWidth]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    } else {
        [coverImgView setContentMode:UIViewContentModeScaleAspectFill];
        [coverImgView.layer setCornerRadius: settings.cornerRadius];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:settings.modalViewWidth]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:settings.modalMediumViewHeight]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    }
    
    if (wrapper.headerText == NO) {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    }
    
    if (wrapper.content == YES) {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-settings.smallMargin]];
    } else if (wrapper.footer == YES && [wrapper isImageAndFloatingFooter] == NO) {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:coverImgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-settings.smallMargin]];
    } else {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:coverImgView attribute:NSLayoutAttributeBottom multiplier:1.0 constant: 0.0]];
    }
}

- (void) setupContentContainer
{
    if (wrapper.title == NO && wrapper.content == NO) {
        return;
    }

    [super setupContentContainer];
    
    [super setupTitle];
    [super setupContentText];
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTitleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant: 0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTitleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant: 0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTitleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:
                             NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentTitleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:contentTitleView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentTitleView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:settings.modalTextPadding]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];


    if (wrapper.image == NO && wrapper.headerText == NO) {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    }
    
    if (wrapper.footer == YES) {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-settings.smallMargin]];
    } else {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant: 0.0]];
    }
}

- (void) setupFooterContainer
{
    if (wrapper.footer == NO) {
        return;
    }
    
    [super setupFooterContainer];
    [button0 setContentEdgeInsets: UIEdgeInsetsMake(5, 10, 5, 10)];
    
    CGFloat margin = [wrapper isImageAndFloatingFooter] == NO ? 0.0 : settings.largeMargin;
    CGFloat negativeMargin = margin != 0.0 ? -margin : 0.0;
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:negativeMargin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:margin]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:layoutWithMarginsView attribute:NSLayoutAttributeRight multiplier:1.0 constant:negativeMargin]];
    

    [constraints addObject: [NSLayoutConstraint constraintWithItem:button0 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:button0 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [constraints addObject: [NSLayoutConstraint constraintWithItem:button0 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    if([[wrapper getFooterItems] count] > 1 ) {
        [button1 setContentEdgeInsets: UIEdgeInsetsMake(5, 10, 5, 10)];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:button0 attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:settings.smallMargin]];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:button1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:button0 attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    } else {
        [constraints addObject: [NSLayoutConstraint constraintWithItem:button0 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:settings.modalViewWidth/2]];
    }
}

- (BOOL) isBorderView
{
    return YES;
}

@end
