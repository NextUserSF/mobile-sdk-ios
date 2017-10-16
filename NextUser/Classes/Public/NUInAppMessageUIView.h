
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NUPopUpShowType) {
    NUPopUpShowTypeNone = 0,
    NUPopUpShowTypeFadeIn,
    NUPopUpShowTypeGrowIn,
    NUPopUpShowTypeShrinkIn,
    NUPopUpShowTypeSlideInFromTop,
    NUPopUpShowTypeSlideInFromBottom,
    NUPopUpShowTypeSlideInFromLeft,
    NUPopUpShowTypeSlideInFromRight,
    NUPopUpShowTypeBounceIn,
    NUPopUpShowTypeBounceInFromTop,
    NUPopUpShowTypeBounceInFromBottom,
    NUPopUpShowTypeBounceInFromLeft,
    NUPopUpShowTypeBounceInFromRight,
};

typedef NS_ENUM(NSInteger, NUPopUpDismissType) {
    NUPopUpDismissTypeNone = 0,
    NUPopUpDismissTypeFadeOut,
    NUPopUpDismissTypeGrowOut,
    NUPopUpDismissTypeShrinkOut,
    NUPopUpDismissTypeSlideOutToTop,
    NUPopUpDismissTypeSlideOutToBottom,
    NUPopUpDismissTypeSlideOutToLeft,
    NUPopUpDismissTypeSlideOutToRight,
    NUPopUpDismissTypeBounceOut,
    NUPopUpDismissTypeBounceOutToTop,
    NUPopUpDismissTypeBounceOutToBottom,
    NUPopUpDismissTypeBounceOutToLeft,
    NUPopUpDismissTypeBounceOutToRight,
};

typedef NS_ENUM(NSInteger, NUPopUpHorizontalLayout) {
    NUPopUpHorizontalLayoutCustom = 0,
    NUPopUpHorizontalLayoutLeft,
    NUPopUpHorizontalLayoutLeftOfCenter,
    NUPopUpHorizontalLayoutCenter,
    NUPopUpHorizontalLayoutRightOfCenter,
    NUPopUpHorizontalLayoutRight,
};

typedef NS_ENUM(NSInteger, NUPopUpVerticalLayout) {
    NUPopUpVerticalLayoutCustom = 0,
    NUPopUpVerticalLayoutTop,
    NUPopUpVerticalLayoutAboveCenter,
    NUPopUpVerticalLayoutCenter,
    NUPopUpVerticalLayoutBelowCenter,
    NUPopUpVerticalLayoutBottom,
};

typedef NS_ENUM(NSInteger, NUPopUpMaskType) {
    NUPopUpMaskTypeNone = 0, // Allow interaction with underlying views.
    NUPopUpMaskTypeClear, // Don't allow interaction with underlying views.
    NUPopUpMaskTypeDimmed, // Don't allow interaction with underlying views, dim background.
};

struct NUPopUpContentMargins {
    CGFloat verticalTop;
    CGFloat verticalBottom;
    CGFloat horizontalLeft;
    CGFloat horizontalRight;
};
typedef struct NUPopUpContentMargins NUPopUpContentMargins;
extern NUPopUpContentMargins NUPopUpContentMarginsMake(CGFloat verticalTop,
                                                       CGFloat verticalBottom,
                                                       CGFloat horizontalLeft,
                                                       CGFloat horizontalRight);

struct NUPopUpLayout {
    NUPopUpHorizontalLayout horizontal;
    NUPopUpVerticalLayout vertical;
    NUPopUpContentMargins contentMargins;
    
};
typedef struct NUPopUpLayout NUPopUpLayout;
extern NUPopUpLayout NUPopUpLayoutMake(NUPopUpHorizontalLayout horizontal,
                                       NUPopUpVerticalLayout vertical);
extern NUPopUpLayout NUPopUpLayoutMakeWithMargins(NUPopUpHorizontalLayout horizontal, NUPopUpVerticalLayout vertical, NUPopUpContentMargins contentMargins);
extern const NUPopUpLayout NUPopUpLayoutCenter;


@interface NUPopUpView : UIView

// This is the view that you want to appear in Popup.
// - Must provide contentView before or in willStartShowing.
// - Must set desired size of contentView before or in willStartShowing.
@property (nonatomic, strong) UIView* contentView;

// Animation transition for presenting contentView. default = shrink in
@property (nonatomic, assign) NUPopUpShowType showType;

// Animation transition for dismissing contentView. default = shrink out
@property (nonatomic, assign) NUPopUpDismissType dismissType;

// Mask prevents background touches from passing to underlying views. default = dimmed.
@property (nonatomic, assign) NUPopUpMaskType maskType;

// Overrides alpha value for dimmed background mask. default = 0.5
@property (nonatomic, assign) CGFloat dimmedMaskAlpha;

// If YES, then popup will get dismissed when background is touched. default = YES.
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;

// If YES, then popup will get dismissed when content view is touched. default = NO.
@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;

// Block gets called after show animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishShowingCompletion)(void);

// Block gets called when dismiss animation starts. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^willStartDismissingCompletion)(void);

// Block gets called after dismiss animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishDismissingCompletion)(void);

// Convenience method for creating popup with default values (mimics UIAlertView).
+ (NUPopUpView*) popupWithContentView:(UIView*)contentView;

// Convenience method for creating popup with custom values.
+ (NUPopUpView*) popupWithContentView:(UIView*)contentView
                         showType:(NUPopUpShowType)showType
                      dismissType:(NUPopUpDismissType)dismissType
                         maskType:(NUPopUpMaskType)maskType
         dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
            dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;

+ (NUPopUpView*) popupWithContentView:(UIView*)contentView
                            withFrame:(CGRect) frame
                             showType:(NUPopUpShowType)showType
                          dismissType:(NUPopUpDismissType)dismissType
                             maskType:(NUPopUpMaskType)maskType
             dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
                dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;

// Dismisses all the popups in the app. Use as a fail-safe for cleaning up.
+ (void)dismissAllPopups;

// Show popup with center layout. Animation determined by showType.
- (void)show;

// Show with specified layout.
- (void)showWithLayout:(NUPopUpLayout)layout;

// Show and then dismiss after duration. 0.0 or less will be considered infinity.
- (void)showWithDuration:(NSTimeInterval)duration;

// Show with layout and dismiss after duration.
- (void)showWithLayout:(NUPopUpLayout)layout duration:(NSTimeInterval)duration;

// Show centered at point in view's coordinate system. If view is nil use screen base coordinates.
- (void)showAtCenter:(CGPoint)center inView:(UIView*)view;

// Show centered at point in view's coordinate system, then dismiss after duration.
- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration;

// Dismiss popup. Uses dismissType if animated is YES.
- (void)dismiss:(BOOL)animated;


#pragma mark Subclassing
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, assign, readonly) BOOL isBeingShown;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, assign, readonly) BOOL isBeingDismissed;

- (void)willStartShowing;
- (void)didFinishShowing;
- (void)willStartDismissing;
- (void)didFinishDismissing;

@end


#pragma mark - UIView Category
@interface UIView(NUPopUpView)
- (void)forEachPopupDoBlock:(void (^)(NUPopUpView* popup))block;
- (void)dismissPresentingPopup;
@end
