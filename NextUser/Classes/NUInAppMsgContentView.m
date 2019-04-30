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
    
    [self setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self setClipsToBounds:YES];
    if ([self isBorderView] == NO) {
        self.backgroundColor = [InAppMsgViewHelper bgColor:wrapper.message.backgroundColor];
    }
    
    if ([wrapper isContentHTML] == YES) {
        [self setupMainContainer];
        [self addSubview:wrapper.webView];
    } else {
        layoutWithMarginsView = [[UIView alloc] init];
        [layoutWithMarginsView setTranslatesAutoresizingMaskIntoConstraints: NO];
        [layoutWithMarginsView setClipsToBounds:YES];
        
        if (wrapper.dismiss == YES || wrapper.headerText == YES) {
            headerView = [[UILabel alloc] init];
            [layoutWithMarginsView addSubview:headerView];
        }
        
        if (wrapper.image == YES) {
            coverImgView = [[UIImageView alloc] init];
            [layoutWithMarginsView addSubview:coverImgView];
        }
        
        if ([wrapper hasBody] == YES) {
            contentView = [[UIView alloc] init];
            [layoutWithMarginsView addSubview:contentView];
            
            if (wrapper.title == YES) {
                contentTitleView = [[UILabel alloc] init];
                [contentView addSubview:contentTitleView];
            }
            
            if (wrapper.content == YES) {
                contentTextView = [[UILabel alloc] init];
                [contentView addSubview:contentTextView];
            }
        }
        
        if (wrapper.footer == YES) {
            footerView = [[UIView alloc] init];
            [layoutWithMarginsView addSubview:footerView];
        }
        
        [self setupMainContainer];
        [self setupMainContainerWithMargins];
        [self setupHeaderContainer];
        [self setupCoverContainer];
        [self setupContentContainer];
        [self setupFooterContainer];
    }
    
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
    [headerView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [headerView setClipsToBounds:YES];
}

- (void) setupHeaderTitle
{
    InAppMsgText *headerTitleMsg = [wrapper getHeader];
    headerTitle = [[UILabel alloc] init];
    [headerView addSubview:headerTitle];
    [headerTitle setClipsToBounds:YES];
    [headerTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [headerTitle setTextColor: [InAppMsgViewHelper textColor:headerTitleMsg.textColor]];
    [headerTitle setFont: [UIFont boldSystemFontOfSize:headerTitleMsg.textSize]];
    [headerTitle setText: headerTitleMsg.text] ;
    [headerTitle setTextAlignment: [InAppMsgViewHelper toTextAlignment:headerTitleMsg.align]];
}

- (void) setupHeaderDismissImg
{
    headerCloseImgView = [[UIImageView alloc] init];
    [headerCloseImgView setTranslatesAutoresizingMaskIntoConstraints: NO];
    headerCloseImgView.contentMode = UIViewContentModeScaleToFill;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                       action:@selector(dismissTapper:)];
    [headerCloseImgView addGestureRecognizer:singleTap];
    [headerCloseImgView setMultipleTouchEnabled:YES];
    [headerCloseImgView setUserInteractionEnabled:YES];
}

- (void) setupCoverContainer
{
    [coverImgView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [coverImgView setClipsToBounds:YES];
    [coverImgView setImage: wrapper.messageImage];
}

- (void) setupContentContainer
{
    [contentView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [contentView setClipsToBounds:YES];
}

- (void) setupTitle
{
    InAppMsgText *titleMsg = [wrapper getTitle];
    [contentTitleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentTitleView setTextColor: [InAppMsgViewHelper textColor:titleMsg.textColor]];
    [contentTitleView setFont: [UIFont boldSystemFontOfSize: titleMsg.textSize]];
    [contentTitleView setText: titleMsg.text];
    [contentTitleView setTextAlignment: [InAppMsgViewHelper toTextAlignment:titleMsg.align]];
    
}

- (void) setupContentText
{
    InAppMsgText *contentMsg = [wrapper getContent];
    [contentTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentTextView setTextColor: [InAppMsgViewHelper textColor:contentMsg.textColor]];
    [contentTextView setFont: [UIFont systemFontOfSize:contentMsg.textSize]];
    [contentTextView setText: contentMsg.text];
    [contentTextView setTextAlignment:[InAppMsgViewHelper toTextAlignment:contentMsg.align]];
    contentTextView.numberOfLines = 5;
}

- (void) setupFooterContainer
{
    [footerView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [footerView setClipsToBounds:YES];
    button0 = [self setupButton:[[wrapper getFooterItems] firstObject] withSelector:@selector(nuButton0Pressed:)];
    [footerView addSubview:button0];
    if([[wrapper getFooterItems] count] > 1 ) {
        button1 = [self setupButton:[[wrapper getFooterItems] lastObject] withSelector:@selector(nuButton1Pressed:)];
        [footerView addSubview:button1];
    }
}

-(void) validate
{
    if (wrapper == nil || wrapper.message == nil) {
        NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Incorrect iam view data"]];
        @throw error;
    }
    
    if ([wrapper isContentHTML] == NO && wrapper.image == YES && (wrapper.messageImage == nil || ([wrapper.messageImage size].height == 0 && [wrapper.messageImage size].width == 0))){
        NSError* error = [NUError nextUserErrorWithMessage: [NSString stringWithFormat:@"Missing image"]];
        @throw error;
    }
}

-(NUUIButton*)setupButton:(InAppMsgButton*) buttonConfig withSelector:(SEL) selector
{
    NUUIButton* button = [NUUIButton buttonWithType:UIButtonTypeCustom];
    [button setTranslatesAutoresizingMaskIntoConstraints: NO];
    button.layer.cornerRadius = settings.cornerRadius;
    
    if (buttonConfig.unSelectedBgColor != nil) {
        [button setBackgroundColor:[InAppMsgViewHelper textColor: buttonConfig.unSelectedBgColor] forState:UIControlStateNormal];
    }
    
    if (buttonConfig.selectedBGColor != nil) {
        [button setBackgroundColor:[InAppMsgViewHelper textColor: buttonConfig.selectedBGColor] forState:UIControlStateNormal];
    }
    
    [button setBackgroundColor:[InAppMsgViewHelper textColor: buttonConfig.selectedBGColor] forState:UIControlStateSelected];
    
    if (buttonConfig.textSize != 0) {
        if (@available(iOS 8.2, *)) {
            [button.titleLabel setFont: [UIFont systemFontOfSize:buttonConfig.textSize weight:UIFontWeightLight]];
        } else {
            // Fallback on earlier versions
        }
    }
    
    [button setTitle:buttonConfig.text forState:UIControlStateNormal];
    
    if (buttonConfig.textColor != nil) {
        [button setTitleColor:[InAppMsgViewHelper textColor: buttonConfig.textColor] forState:UIControlStateNormal];
    } else {
        [button setTitleColor:[[button titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    }
    
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchDown];
    
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

- (BOOL) isBorderView
{
    return NO;
}

@end
