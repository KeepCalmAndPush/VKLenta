//
//  GradientView.m
//  BigBookTest
//
//  Created by Андрей Соловьев on 11/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import "GradientView.h"


@interface GradientView ()

@property (nonatomic) CAGradientLayer *gradientLayer;
@property (nonatomic, readwrite) UIColor *topColor;
@property (nonatomic, readwrite) UIColor *bottomColor;

@end

@implementation GradientView

- (instancetype)initWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        self.topColor = topColor;
        self.bottomColor = bottomColor;
        
        _gradientLayer = [CAGradientLayer new];
        _gradientLayer.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
        [self.layer addSublayer:_gradientLayer];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.gradientLayer.frame = self.bounds;
}

@end
