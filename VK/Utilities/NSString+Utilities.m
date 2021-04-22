//
//  NSString+Utilities.m
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

- (NSString *)stringWithUppercasedFirstCharacter {
    if(!self.length) {
        return self;
    }
    
    if(self.length == 1) {
        return self.uppercaseString;
    }
    
    unichar character = [self characterAtIndex:0];
    NSString *uppercasedFirstCharacter = [NSString stringWithCharacters:&character
                                                                 length:1].uppercaseString;
    
    NSString *result = [self stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                     withString:uppercasedFirstCharacter];
    
    return result;
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary *attributes = @{NSParagraphStyleAttributeName : paragraphStyle,
                                 NSFontAttributeName : font};
    
    [attributedString setAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    
    CGSize result = [attributedString boundingRectWithSize:size
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil].size;
    return result;
}


@end
