//
//  UIColor+Utilities.h
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import <UIKit/UIKit.h>

static inline UIColor *rgb(NSInteger red, NSInteger green, NSInteger blue) {
    return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:1.0];
}

static inline UIColor *rgba(NSInteger red, NSInteger green, NSInteger blue, CGFloat alpha) {
    return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:alpha];
}

@interface UIColor (Utilities)

@end
