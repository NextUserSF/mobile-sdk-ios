//
//  NUInAppMsgContentView.m
//  Pods
//
//  Created by Adrian Lazea on 31/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "NUInAppMsgContentView.h"
#import "UIColor+CreateMethods.h"
#import "NUInAppMsgViewHelper.h"

@interface InAppMsgContentView ()


@end

@implementation InAppMsgContentView



-(instancetype)initWithWrapper:(InAppMsgWrapper*) messageWrapper withSettings:(InAppMsgViewSettings*) viewSettings
{
    if (self = [super init]) {
        wrapper = messageWrapper;
        settings = viewSettings;
        constraints = [[NSMutableArray<NSLayoutConstraint *> alloc] init];
        [self build];
    }
    
    return self;
}

- (NUPopUpLayout) getLayout
{
    return mainLayout;
}


-(void) build
{
    [self validate];
    
    self.backgroundColor = [InAppMsgViewHelper bgColor:wrapper.message.backgroundColor];
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self setClipsToBounds:YES];
    [self setupMainContainer];
    
    layoutWithMarginsView = [[UIView alloc] init];
    [layoutWithMarginsView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [layoutWithMarginsView setClipsToBounds:YES];
    [self addSubview:layoutWithMarginsView];
    [self setupMainContainerWithMargins];
    
    [self setupHeaderContainer];
    [self setupCoverContainer];
    [self setupContentContainer];
    [self setupFooterContainer];
    
    mainLayout = [self createLayout];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void) setupMainContainer
{

}

- (void) setupMainContainerWithMargins;
{

}

- (void) setupHeaderContainer
{
    headerView = [[UIView alloc] init];
    [headerView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [headerView setClipsToBounds:YES];
    [layoutWithMarginsView addSubview:headerView];
}

- (void) setupHeaderTitle
{
    InAppMsgText *headerTitleMsg = [wrapper getHeader];
    headerTitle = [[UILabel alloc] init];
    [headerTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    headerTitle.textColor = [InAppMsgViewHelper textColor:headerTitleMsg.textColor];
    headerTitle.font = [UIFont boldSystemFontOfSize:12.0];
    headerTitle.text = headerTitleMsg.text;
    headerTitle.textAlignment = [InAppMsgViewHelper toTextAlignment:headerTitleMsg.align];
    [headerView addSubview:headerTitle];
}

- (void) setupHeaderDismissImg
{
    headerCloseImgView = [[UIImageView alloc] init];
    [headerCloseImgView setTranslatesAutoresizingMaskIntoConstraints: NO];
//    UIImage* chevronRightImage = [UIImage imageNamed:@"chevron_right.png"];
    headerCloseImgView.contentMode = UIViewContentModeCenter;
    [headerView addSubview:headerCloseImgView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                       action:@selector(dismissTapper:)];
    [headerCloseImgView addGestureRecognizer:singleTap];
    [headerCloseImgView setMultipleTouchEnabled:YES];
    [headerCloseImgView setUserInteractionEnabled:YES];
    [headerView addSubview:headerCloseImgView];
}

- (void) setupCoverContainer
{
    coverImgView = [[UIImageView alloc] init];
    [coverImgView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [coverImgView setClipsToBounds:YES];
    coverImgView.image = wrapper.messageImage;
    [self addSubview:coverImgView];
}

- (void) setupContentContainer
{
    contentView = [[UIView alloc] init];
    [contentView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [contentView setClipsToBounds:YES];
    [layoutWithMarginsView addSubview:contentView];
}

- (void) setupTitle
{
    InAppMsgText *titleMsg = [wrapper getTitle];
    contentTitleView = [[UILabel alloc] init];
    [contentTitleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    contentTitleView.textColor = [InAppMsgViewHelper textColor:titleMsg.textColor];
    contentTitleView.font = [UIFont boldSystemFontOfSize:settings.contentTitleFontSize];
    contentTitleView.text = titleMsg.text;
    contentTitleView.textAlignment = [InAppMsgViewHelper toTextAlignment:titleMsg.align];
    [contentView addSubview:contentTitleView];
}

- (void) setupContentText
{
    InAppMsgText *contentMsg = [wrapper getContent];
    contentTextView = [[UILabel alloc] init];
    [contentTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    contentTextView.textColor = [InAppMsgViewHelper textColor:contentMsg.textColor];
    contentTextView.font = [UIFont boldSystemFontOfSize:12.0];
    contentTextView.text = contentMsg.text;
    contentTextView.textAlignment = [InAppMsgViewHelper toTextAlignment:contentMsg.align];
    contentTextView.numberOfLines = 5;
    [contentView addSubview:contentTextView];
}

- (void) setupFooterContainer
{
    footerView = [[UIView alloc] init];
    if (wrapper.footer == YES) {
        [self addSubview:footerView];
        button0 = [self setupButton:[[wrapper getFooterItems] firstObject] withSelector:@selector(nuButton0Pressed:)];
        [footerView addSubview:button0];
        if([[wrapper getFooterItems] count] > 1 ) {
            button1 = [self setupButton:[[wrapper getFooterItems] lastObject] withSelector:@selector(nuButton1Pressed:)];
            [footerView addSubview:button1];
        }
    }
}

-(void) validate
{
    if (wrapper == nil || wrapper.message == nil) {
        NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Incorrect iam view data"]];
        @throw error;
    }
    
    if (wrapper.image ==YES && (wrapper.messageImage == nil || ([wrapper.messageImage size].height == 0 && [wrapper.messageImage size].width == 0))){
        NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Missing image"]];
        @throw error;
    }
}

-(NUUIButton*)setupButton:(InAppMsgButton*) buttonConfig withSelector:(SEL) selector
{
    NUUIButton* button = [NUUIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    
    [button setBackgroundColor:[InAppMsgViewHelper textColor: buttonConfig.unSelectedBgColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[InAppMsgViewHelper textColor: buttonConfig.unSelectedBgColor] forState:UIControlStateSelected];
    
    //button.layer.contentsGravity
    button.titleLabel.font = [UIFont systemFontOfSize:settings.headerTitleFontSize weight:UIFontWeightLight];
    [button setTitle:buttonConfig.text forState:UIControlStateNormal];
    [button setTitleColor:[InAppMsgViewHelper textColor: buttonConfig.textColor] forState:UIControlStateNormal];
    [button setTitleColor:[[button titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(selector) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


- (void)dismissTapper:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        InAppMsgClick* dismissClickConfig = [wrapper getDismissClickConfiguration];
        [wrapper.interactionListener onInteract:dismissClickConfig];
        return;
    }
}

- (void)nuButton0Pressed:(id)sender {
    if ([sender isKindOfClass:[UIView class]]) {
        InAppMsgClick* btn0ClickConfig = [wrapper getClick0Configuration];
        [wrapper.interactionListener onInteract:btn0ClickConfig];

        return;
    }
}

- (void)nuButton1Pressed:(id)sender {
    if ([sender isKindOfClass:[UIView class]]) {
        InAppMsgClick* btn1ClickConfig = [wrapper getClick1Configuration];
        [wrapper.interactionListener onInteract:btn1ClickConfig];
        
        return;
    }
}

-(NUPopUpLayout) createLayout
{
    return NUPopUpLayoutCenter;
}

@end
