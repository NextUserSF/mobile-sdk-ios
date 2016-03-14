//
//  NUInAppMessageView.m
//  NextUserKit
//
//  Created by Dino on 3/9/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NUInAppMessageView.h"
#import "NUPushMessage.h"

@interface NUInAppMessageView ()

@property (nonatomic) NUPushMessage *message;
@property (nonatomic) CGSize maxSize;

@end

@implementation NUInAppMessageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
//    UINib *nib = [UINib nibWithNibName:@"NUInAppMessageView" bundle:nil];
//    NSArray *topLevelObjects = [nib instantiateWithOwner:self options:nil];
//    UIView *view = topLevelObjects.firstObject;
//    view.frame = self.bounds;
//    [self addSubview:view];
    
    NSBundle * frameworkBundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:@"NUInAppMessageView"
                                bundle:frameworkBundle];
    
    NSArray *objects = [nib instantiateWithOwner:self options:nil];
    NSLog(@"smh");
    
//    NUInAppMessageView *view = [[frameworkBundle loadNibNamed:@"NUInAppMessageView" owner:self options:nil] firstObject];
//    view.frame = self.bounds;
//    [self addSubview:view];
}

#pragma mark - Factory

+ (NUInAppMessageView *)viewForMessage:(NUPushMessage *)message withMaxSize:(CGSize)maxSize
{
    CGRect frame = CGRectMake(0, 0, maxSize.width, maxSize.height);
    NUInAppMessageView *messageView = [[NUInAppMessageView alloc] initWithFrame:frame];
    
    return messageView;
}

@end
