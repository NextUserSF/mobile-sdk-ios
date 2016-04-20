//
//  NURoundedDismissButton.m
//  NextUserKit
//
//  Created by Dino on 4/20/16.
//  Copyright © 2016 NextUser. All rights reserved.
//

#import "NURoundedDismissButton.h"

@interface NURoundedDismissButton ()

@property (nonatomic) CAShapeLayer *backgroundOvalLayer;
@property (nonatomic) CAShapeLayer *crossLayer;

@end

@implementation NURoundedDismissButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

#pragma mark -

- (void)commonInit
{
    CGRect bounds = self.bounds;
    
    _backgroundOvalLayer = [self.class roundedBackgroundLayerInBounds:bounds];
    _crossLayer = [self.class crossLayerInBounds:bounds];

    [_backgroundOvalLayer addSublayer:_crossLayer];
    [self.layer addSublayer:_backgroundOvalLayer];
}

+ (CAShapeLayer *)roundedBackgroundLayerInBounds:(CGRect)bounds
{
    CAShapeLayer *ovalLayer = [CAShapeLayer layer];
    ovalLayer.frame = bounds;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(bounds), bounds.size.height)
                                          radius:CGRectGetMidX(bounds)
                                      startAngle:-M_PI
                                        endAngle:0
                                       clockwise:YES];
    ovalLayer.path = [path CGPath];
    
    return ovalLayer;
}

+ (CAShapeLayer *)crossLayerInBounds:(CGRect)bounds
{
    CGFloat crossSize = bounds.size.height/2.0 * 0.4;
    CGRect crossRect = CGRectMake(bounds.size.width/2.0 - crossSize/2.0,
                                  bounds.size.height - crossSize - 2,
                                  crossSize,
                                  crossSize);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = crossRect;
    layer.lineCap = kCALineCapRound;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(crossSize, crossSize)];
    [path moveToPoint:CGPointMake(crossSize, 0)];
    [path addLineToPoint:CGPointMake(0, crossSize)];
    
    layer.path = path.CGPath;
    
    layer.lineWidth = 2;
    
    return layer;
}

#pragma mark -

- (void)setColor:(UIColor *)color
{
    _color = color;
    _backgroundOvalLayer.fillColor = color.CGColor;
    
    _crossLayer.strokeColor = [UIColor darkGrayColor].CGColor;
}

@end
