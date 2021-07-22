#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol NUProgressDialogDelegate;


typedef NS_ENUM(NSInteger, NUProgressDialogDisplayMode) {
    /** Progress is shown using an UIActivityIndicatorView. This is the default. */
    NUProgressDialogModeIndeterminate,
    /** Progress is shown using a round, pie-chart like, progress view. */
    NUProgressDialogModeDeterminate,
    /** Progress is shown using a horizontal progress bar */
    NUProgressDialogModeDeterminateHorizontalBar,
    /** Progress is shown using a ring-shaped progress view. */
    NUProgressDialogModeAnnularDeterminate,
    /** Shows a custom view */
    NUProgressDialogModeCustomView,
    /** Shows only labels */
    NUProgressDialogModeText
};

typedef NS_ENUM(NSInteger, NUProgressDialogAnimation) {
    /** Opacity animation */
    NUProgressDialogAnimationFade,
    /** Opacity + scale animation */
    NUProgressDialogAnimationZoom,
    NUProgressDialogAnimationZoomOut = NUProgressDialogAnimationZoom,
    NUProgressDialogAnimationZoomIn
};


#ifndef NU_INSTANCETYPE
#if __has_feature(objc_instancetype)
    #define NU_INSTANCETYPE instancetype
#else
    #define NU_INSTANCETYPE id
#endif
#endif

#ifndef NU_STRONG
#if __has_feature(objc_arc)
    #define NU_STRONG strong
#else
    #define NU_STRONG retain
#endif
#endif

#ifndef NU_WEAK
#if __has_feature(objc_arc_weak)
    #define NU_WEAK weak
#elif __has_feature(objc_arc)
    #define NU_WEAK unsafe_unretained
#else
    #define NU_WEAK assign
#endif
#endif

#if NS_BLOCKS_AVAILABLE
typedef void (^NUProgressDialogCompletionBlock)(void);
#endif

@interface NUProgressDialog : UIView

+ (NU_INSTANCETYPE)showDialogAddedTo:(UIView *)view animated:(BOOL)animated;
+ (BOOL)hideDialogForView:(UIView *)view animated:(BOOL)animated;
+ (NSUInteger)hideAllDialogsForView:(UIView *)view animated:(BOOL)animated;
+ (NU_INSTANCETYPE)dialogForView:(UIView *)view;
+ (NSArray *)allDialogsForView:(UIView *)view;
- (id)initWithWindow:(UIWindow *)window;
- (id)initWithView:(UIView *)view;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;
- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay;
- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated;

#if NS_BLOCKS_AVAILABLE

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block;
- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block completionBlock:(NUProgressDialogCompletionBlock)completion;
- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue;
- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue
          completionBlock:(NUProgressDialogCompletionBlock)completion;
@property (copy) NUProgressDialogCompletionBlock completionBlock;

#endif


@property (assign) NUProgressDialogDisplayMode mode;
@property (assign) NUProgressDialogAnimation animationType;
@property (NU_STRONG) UIView *customView;
@property (NU_WEAK) id<NUProgressDialogDelegate> delegate;
@property (copy) NSString *labelText;
@property (copy) NSString *detailsLabelText;
@property (assign) float opacity;
@property (NU_STRONG) UIColor *color;
@property (assign) float xOffset;
@property (assign) float yOffset;
@property (assign) float margin;
@property (assign) float cornerRadius;
@property (assign) BOOL dimBackground;
@property (assign) float graceTime;
@property (assign) float minShowTime;
@property (assign) BOOL taskInProgress;
@property (assign) BOOL removeFromSuperViewOnHide;
@property (NU_STRONG) UIFont* labelFont;
@property (NU_STRONG) UIColor* labelColor;
@property (NU_STRONG) UIFont* detailsLabelFont;
@property (NU_STRONG) UIColor* detailsLabelColor;
@property (NU_STRONG) UIColor *activityIndicatorColor;
@property (assign) float progress;
@property (assign) CGSize minSize;
@property (atomic, assign, readonly) CGSize size;
@property (assign, getter = isSquare) BOOL square;

@end


@protocol NUProgressDialogDelegate <NSObject>
@optional
- (void)dialogWasHidden:(NUProgressDialog *)dialog;
@end


@interface NURoundProgressView : UIView

@property (nonatomic, assign) float progress;
@property (nonatomic, NU_STRONG) UIColor *progressTintColor;
@property (nonatomic, NU_STRONG) UIColor *backgroundTintColor;
@property (nonatomic, assign, getter = isAnnular) BOOL annular;

@end


@interface NUBarProgressView : UIView


@property (nonatomic, assign) float progress;
@property (nonatomic, NU_STRONG) UIColor *lineColor;
@property (nonatomic, NU_STRONG) UIColor *progressRemainingColor;
@property (nonatomic, NU_STRONG) UIColor *progressColor;

@end

