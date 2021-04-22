//
//  GradientView.h
//  BigBookTest
//
//  Created by Андрей Соловьев on 11/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientView : UIView

- (instancetype)initWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor;

@property (nonatomic, readonly) UIColor *topColor;
@property (nonatomic, readonly) UIColor *bottomColor;

@end
