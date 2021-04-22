//
//  NSString+Utilities.h
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Utilities)

- (NSString *)stringWithUppercasedFirstCharacter;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
