//
//  FeedItemActionsBar.m
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import "FeedItemActionsBar.h"
#import "FeedCollectionViewModels.h"
#import "UIColor+Utilities.h"
#import "UIView+Utilities.h"

static const CGFloat ViewsButtonLeftMargin = 26;

@interface FeedItemActionsBar()
@property (nonatomic) UIButton *likesButton;
@property (nonatomic) UIButton *commentsButton;
@property (nonatomic) UIButton *repostsButton;
@property (nonatomic) UIButton *viewsButton;
@end


@implementation FeedItemActionsBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self placeButtons];
    }
    
    return self;
}

- (void)placeButtons {
    self.likesButton = [self makeActionButtonWithImageNamed:@"likes_icon"];
    self.commentsButton = [self makeActionButtonWithImageNamed:@"comments_icon"];
    self.repostsButton = [self makeActionButtonWithImageNamed:@"reposts_icon"];
    self.viewsButton = [self makeActionButtonWithImageNamed:@"views_icon"];
    
    [self addSubview:self.likesButton];
    [self addSubview:self.commentsButton];
    [self addSubview:self.repostsButton];
    [self addSubview:self.viewsButton];
}

- (UIButton *)makeActionButtonWithImageNamed:(NSString *)imageName{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:image forState:UIControlStateNormal];
    
    UIColor *tintColor = rgb(0x81, 0x8c, 0x99);
    button.tintColor = tintColor;
    button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    UIEdgeInsets imageEdgeInsets = button.imageEdgeInsets;
    imageEdgeInsets.left -= 6;
    button.imageEdgeInsets = imageEdgeInsets;
    
    return button;
}

- (void)setModel:(FeedItemActionsBarModel *)model {
    _model = model;
    [self updateInterface];
}

- (void)updateInterface {
    [self setTitle:self.model.likesCountFormatted onButton:self.likesButton];
    [self setTitle:self.model.commentsCountFormatted onButton:self.commentsButton];
    [self setTitle:self.model.repostsCountFormatted onButton:self.repostsButton];
    [self setTitle:self.model.viewsCountFormatted onButton:self.viewsButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutButtons];
}

- (void)layoutButtons {
    CGFloat availableWidthForButtons = self.width - ViewsButtonLeftMargin;
    CGFloat buttonWidth = floor(availableWidthForButtons / 4);
    CGRect buttonFrame = self.bounds;
    buttonFrame.size.width = buttonWidth;
    
    for (UIButton *b in @[self.likesButton, self.commentsButton, self.repostsButton]) {
        b.frame = buttonFrame;
        buttonFrame.origin.x += b.width;
    }
    
    buttonFrame.origin.x += ViewsButtonLeftMargin;
    self.viewsButton.frame = buttonFrame;
}

- (void)setTitle:(NSString *)title onButton:(UIButton *)button {
    NSDictionary *attributes = @{NSForegroundColorAttributeName : button.tintColor,
                                 NSFontAttributeName : [UIFont systemFontOfSize:14 weight:UIFontWeightMedium]};

    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    [button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

@end
