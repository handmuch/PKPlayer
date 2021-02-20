//
//  PKSpectrumView.m
//  PKPlayer
//
//  Created by 郭建华 on 2019/5/13.
//  Copyright © 2019 PeterKwok. All rights reserved.
//

#import "PKSpectrumView.h"

static const CGFloat barWidth = 3.0f;
static const CGFloat space =  1.0f;

@interface PKSpectrumView ()

@property (nonatomic, assign) CGFloat bottomSpace;
@property (nonatomic, assign) CGFloat topSpace;

@property (nonatomic, strong) CAGradientLayer *leftGradientLayer;
@property (nonatomic, strong) CAGradientLayer *rightGradientLayer;

@end

@implementation PKSpectrumView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.barWidth = barWidth;
        self.space = space;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor blackColor];
    
    self.rightGradientLayer = [CAGradientLayer layer];
    self.rightGradientLayer.colors = @[(id)[UIColor colorWithRed:52.0/255.0 green:232.0/255.0 blue:158.0/255.0 alpha:1.0].CGColor, (id)[UIColor colorWithRed:15.0/255.0 green:52.0/255.0 blue:67.0/255.0 alpha:1.0].CGColor];
    self.rightGradientLayer.locations = @[@(0.6), @(1.0)];
    [self.layer addSublayer:self.rightGradientLayer];
    
    self.leftGradientLayer = [CAGradientLayer layer];
    self.leftGradientLayer.colors = @[(id)[UIColor colorWithRed:194.0/255.0 green:21.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor, (id)[UIColor colorWithRed:255.0/255.0 green:197.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor];
    self.leftGradientLayer.locations = @[@(0.6), @(1.0)];
    [self.layer addSublayer:self.leftGradientLayer];
}

- (CGFloat)translateAmplitudeToYPositionAmplitude:(CGFloat)amplitude {
    CGFloat barHeight = amplitude * (self.bounds.size.height - self.bottomSpace - self.topSpace);
    return self.bounds.size.height - self.bottomSpace - barHeight;
}

#pragma mark - setter

- (void)setSpeatra:(NSMutableArray <NSArray<NSNumber *> *> *)speatra {
    _speatra = speatra;
    
    self.barWidth = barWidth;
    self.space = space;
    
    self.bottomSpace = 0.0f;
    self.topSpace = 0.0f;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    //left channel
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    NSArray *spectraLeft = speatra.firstObject;
    for (int i = 0; i < spectraLeft.count; i++) {
        CGFloat amplitude = [[spectraLeft objectAtIndex:i] floatValue];
        CGFloat x = (CGFloat)i * (self.barWidth + self.space) + self.space;
        CGFloat y = [self translateAmplitudeToYPositionAmplitude:amplitude];
        UIBezierPath *bar = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, self.barWidth, self.bounds.size.height - self.bottomSpace - y)];
        [leftPath appendPath:bar];
    }
    CAShapeLayer *leftMaskLayer = [CAShapeLayer layer];
    leftMaskLayer.path = leftPath.CGPath;
    self.leftGradientLayer.frame = CGRectMake(0, self.topSpace, self.bounds.size.width, self.bounds.size.height - self.topSpace - self.bottomSpace);
    self.leftGradientLayer.mask = leftMaskLayer;
    
    // right channel
    if (speatra.count >= 2) {
        UIBezierPath *rightPath = [UIBezierPath bezierPath];
        NSArray *spectraRight = [speatra objectAtIndex:1];
        for (int i = 0; i < spectraRight.count; i++) {
            CGFloat amplitude = [[spectraLeft objectAtIndex:i] floatValue];
            CGFloat x = (CGFloat)(spectraRight.count - 1 - i) * (self.barWidth + self.space) + self.space;
            CGFloat y = [self translateAmplitudeToYPositionAmplitude:amplitude];
            UIBezierPath *bar = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, barWidth, self.bounds.size.height - self.bottomSpace - y)];
            [rightPath appendPath:bar];
        }
        CAShapeLayer *rigthMaskLayer = [CAShapeLayer layer];
        rigthMaskLayer.path = rightPath.CGPath;
        self.rightGradientLayer.frame = CGRectMake(0, self.topSpace, self.bounds.size.width, self.bounds.size.height - self.topSpace - self.bottomSpace);
        self.rightGradientLayer.mask = rigthMaskLayer;
    }
    [CATransaction commit];
}

@end
