//
//  FeedItemCollectionViewCell.m
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import "FeedItemCollectionViewCell.h"
#import "FeedItemPhotosCarousel.h"
#import "FeedItemActionsBar.h"
#import "FeedCollectionViewModels.h"
#import "UIView+Utilities.h"
#import "NSString+Utilities.h"
#import "UIColor+Utilities.h"
#import "VKApiInteractor.h"

static const CGFloat DefaultContentInset = 12.0;

static const CGFloat UserImageViewDimensions = 36.0;
static const CGFloat UserImageViewMarginRight = 10.0;

static const CGFloat UserNameLabelMarginTop = 1.0;
static const CGFloat DateLabelMarginTop = 2.0;

static const CGFloat TextLabelMarginTop = 10.0;
static const CGFloat PhotoViewMarginTop = 10.0;

static const CGFloat SinglePhotoImageViewHeight = 270.0;
static const CGFloat PhotosCarouselHeight = 290.0;
static const CGFloat ActionsBarHeight = 44.0;

#define TextFont [UIFont systemFontOfSize:15]
#define ReadMoreButtonHeight TextFont.lineHeight
#define TextLabelMaxHeight TextFont.lineHeight * 8
static const NSLineBreakMode TextLineBreakMode = NSLineBreakByWordWrapping;

@interface FeedItemCollectionViewCell () <FeedItemPhotosCarouselDelegate>

@property (nonatomic) UIImageView *userAvatarImageView;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UIButton *readMoreButton;
@property (nonatomic) UIImageView *singlePhotoImageView;
@property (nonatomic) FeedItemPhotosCarousel *photosCarousel;
@property (nonatomic) FeedItemActionsBar *actionsBar;

@end


@implementation FeedItemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setSubviewsBackgroundColor:[UIColor whiteColor]];
        
        [self setupShadowAndCorners];
    }
    return self;
}

- (void)setupShadowAndCorners {
    [self beginRasterizing];


    self.layer.shadowOffset = CGSizeMake(0, 24);
    self.layer.shadowRadius = 18.0;
    self.layer.shadowColor = rgb(0x63, 0x67, 0x6f).CGColor;
    self.layer.shadowOpacity = 0.07;

    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 10;
    self.contentView.clearsContextBeforeDrawing = NO;
}

- (void)setSubviewsBackgroundColor:(UIColor *)backgroundColor {
    
    for (UIView *view in @[self.contentView,
                           self.userAvatarImageView,
                           self.userNameLabel,
                           self.dateLabel,
                           self.textLabel,
                           self.readMoreButton,
                           self.singlePhotoImageView,
                           self.photosCarousel,
                           self.actionsBar]) {
        
        view.backgroundColor = backgroundColor;
    }
}

- (void)setModel:(FeedItemCollectionViewModel *)model {
    _model = model;
    
    [self updateInterface];
}

- (void)updateInterface {
    [VKApiInteractor.sharedInstance loadImageWithURL:self.model.userAvatarImageURL
                                          completion:^(UIImage *image, NSURL *url, NSError *networkError) {
                                              if ([url isEqual:self.model.userAvatarImageURL]) {
                                                  self.userAvatarImageView.image = image;
                                                  self.userAvatarImageView.backgroundColor = self.contentView.backgroundColor;
                                              }
                                          }];
    self.userNameLabel.text = self.model.userName;
    self.dateLabel.text = self.model.dateFormatted;
    self.textLabel.text = self.model.text;
    self.textLabel.hidden = self.model.text.length == 0;
    self.readMoreButton.hidden = self.isReadMoreButtonHidden;
    
    self.singlePhotoImageView.hidden = YES;
    self.photosCarousel.hidden = YES;

    if (self.model.photosURLs.count > 1) {
        self.photosCarousel.hidden = NO;
        self.photosCarousel.photosURLs = self.model.photosURLs;
    } else if (self.model.photosURLs.count == 1) {
        self.singlePhotoImageView.hidden = NO;
        
        [VKApiInteractor.sharedInstance loadImageWithURL:self.model.photosURLs.firstObject
                                              completion:^(UIImage *image, NSURL *url, NSError *networkError) {
                                                  if ([url isEqual:self.model.photosURLs.firstObject]) {
                                                      self.singlePhotoImageView.image = image;
                                                      self.singlePhotoImageView.backgroundColor = self.contentView.backgroundColor;
                                                  }
                                              }];
    }
    
    self.actionsBar.model = self.model.actionsBarModel;
    [self setNeedsLayout];
}

- (BOOL)isReadMoreButtonHidden {
    CGFloat width = self.contentView.width - 2*TextLabelMarginTop;
    
    CGFloat rawTextHeight = [self.class heightForRawTextWithModel:self.model
                                                        labelWidth:width];
    
    BOOL shouldShowMoreButton = [self.class shouldShowMoreButtonForTextHeight:rawTextHeight
                                                                        model:self.model];
    
    return !shouldShowMoreButton;
}

#pragma mark - Subviews creation

- (UIImageView *)userAvatarImageView {
    if (!_userAvatarImageView) {
        _userAvatarImageView = [UIImageView new];
        _userAvatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _userAvatarImageView.opaque = YES;
        _userAvatarImageView.layer.cornerRadius = UserImageViewDimensions / 2;
        _userAvatarImageView.layer.masksToBounds = YES;
        _userAvatarImageView.backgroundColor = [UIColor lightGrayColor];
        
        [self.contentView addSubview:_userAvatarImageView];
    }
    
    return _userAvatarImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [UILabel new];
        _userNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _userNameLabel.textColor = rgb(0x2c, 0x2d, 0x2e);
        _userNameLabel.opaque = YES;
        
        [self.contentView addSubview:_userNameLabel];
    }
    
    return _userNameLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _dateLabel.textColor = rgb(0x81, 0x8c, 0x99);
        _dateLabel.opaque = YES;
        
        [self.contentView addSubview:_dateLabel];
    }
    
    return _dateLabel;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.font = TextFont;
        _textLabel.textColor = rgb(0x2a, 0x2d, 0x31);
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = TextLineBreakMode;
        _textLabel.opaque = YES;
        
        [self.contentView addSubview:_textLabel];
    }
    
    return _textLabel;
}


- (UIButton *)readMoreButton {
    if (!_readMoreButton) {
        _readMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSDictionary *attibutes = @{NSForegroundColorAttributeName : rgb(82, 139, 204),
                                    NSFontAttributeName : TextFont};
        
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Показать полностью..."
                                                                          attributes:attibutes];
        
        [_readMoreButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
        
        [_readMoreButton addTarget:self
                            action:@selector(moreButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
        
        _readMoreButton.opaque = YES;
        
        [self.contentView addSubview:_readMoreButton];
    }
    
    return _readMoreButton;
}

- (UIImageView *)singlePhotoImageView {
    if (!_singlePhotoImageView) {
        _singlePhotoImageView = [UIImageView new];
        _singlePhotoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _singlePhotoImageView.opaque = YES;
        _singlePhotoImageView.backgroundColor = [UIColor lightGrayColor];
        
        [self.contentView addSubview:_singlePhotoImageView];
    }
    
    return _singlePhotoImageView;
}

- (FeedItemPhotosCarousel *)photosCarousel {
    if (!_photosCarousel) {
        _photosCarousel = [FeedItemPhotosCarousel new];
        _photosCarousel.carouselDelegate = self;
        _photosCarousel.opaque = YES;
        
        [self.contentView addSubview:_photosCarousel];
    }
    
    return _photosCarousel;
}

- (FeedItemActionsBar *)actionsBar {
    if (!_actionsBar) {
        _actionsBar = [FeedItemActionsBar new];
        _actionsBar.opaque = YES;
        
        [self.contentView addSubview:_actionsBar];
    }
    
    return _actionsBar;
}

#pragma mark - Manual layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds cornerRadius:10] CGPath];
    [self layoutUserAvatarImageView];
    [self layoutUserNameLabel];
    [self layoutDateLabel];
    [self layoutUserNameLabel];
    [self layoutTextLabel];
    [self layoutReadMoreButton];
    [self layoutSinglePhotoImageView];
    [self layoutPhotosCarousel];
    [self layoutActionsBar];
}

- (void)layoutContentView {
    CGRect frame = CGRectInset(self.bounds, 8, 0);
    self.contentView.frame = frame;
}

- (void)layoutUserAvatarImageView {
    CGRect avatarFrame = CGRectMake(DefaultContentInset,
                                    DefaultContentInset,
                                    UserImageViewDimensions,
                                    UserImageViewDimensions);
    
    self.userAvatarImageView.frame = CGRectIntegral(avatarFrame);
}

- (void)layoutUserNameLabel {
    CGFloat originX = self.userAvatarImageView.right + UserImageViewMarginRight;
    
    CGRect userNameLabelFrame = CGRectMake(originX,
                                           self.userAvatarImageView.top + UserNameLabelMarginTop,
                                           self.contentView.width - originX - DefaultContentInset,
                                           self.userNameLabel.font.lineHeight);
    
    self.userNameLabel.frame = CGRectIntegral(userNameLabelFrame);
}

- (void)layoutDateLabel {
    CGRect dateLabelFrame = self.userNameLabel.frame;
    dateLabelFrame.size.height = self.dateLabel.font.lineHeight;
    dateLabelFrame.origin.y = self.userNameLabel.bottom + DateLabelMarginTop;
    
    self.dateLabel.frame = CGRectIntegral(dateLabelFrame);
}

- (void)layoutTextLabel {
    CGFloat width = self.contentView.width - 2*TextLabelMarginTop;
    
    CGFloat textHeight = [self.class heightForTextLabelWithModel:self.model
                                                      labelWidth: width];
    
    CGRect textLabelFrame = CGRectMake(DefaultContentInset,
                                  self.userAvatarImageView.bottom + UserImageViewMarginRight,
                                  self.contentView.width - 2*TextLabelMarginTop,
                                  floor(textHeight));
    
    self.textLabel.frame = textLabelFrame;//CGRectIntegral(textLabelFrame);
}


- (void)layoutReadMoreButton {
    [self.readMoreButton sizeToFit];
    
    CGRect readMoreButtonFrame = CGRectMake(self.textLabel.left,
                                            self.textLabel.bottom,
                                            self.readMoreButton.width,
                                            floor(self.textLabel.font.lineHeight));
    
    self.readMoreButton.frame = readMoreButtonFrame;//CGRectIntegral(readMoreButtonFrame);
}

- (void)layoutSinglePhotoImageView {
    CGFloat originY = [self photosViewOriginY];
    CGRect singlePhotoImageViewFrame = CGRectMake(0.0,
                                                  originY,
                                                  self.contentView.width,
                                                  SinglePhotoImageViewHeight);
    
    self.singlePhotoImageView.frame = CGRectIntegral(singlePhotoImageViewFrame);
}

- (void)layoutPhotosCarousel {
    CGFloat originY = [self photosViewOriginY];
    CGRect photosCarouselFrame = CGRectMake(0.0,
                                            originY,
                                            self.contentView.width,
                                            PhotosCarouselHeight);
    
    self.photosCarousel.frame = CGRectIntegral(photosCarouselFrame);
}

- (CGFloat)photosViewOriginY {
    CGFloat originY = PhotoViewMarginTop;
    
    if (self.textLabel.hidden) {
        originY += self.userAvatarImageView.bottom;
    } else if (self.readMoreButton.hidden) {
        originY += self.textLabel.bottom;
    } else {
        originY += self.readMoreButton.bottom;
    }
        
    return originY;
}

- (void)layoutActionsBar {
    CGRect actionsBarFrame = CGRectMake(0,
                                        self.contentView.height - ActionsBarHeight,
                                        self.contentView.width,
                                        ActionsBarHeight);
    
    self.actionsBar.frame = CGRectIntegral(actionsBarFrame);
}

+ (CGFloat)heightWithModel:(FeedItemCollectionViewModel *)model cellWidth:(CGFloat)width {
    
    CGFloat labelWidth = width - (2 * DefaultContentInset); // From cell width to label width;
    
    CGFloat height = DefaultContentInset + UserImageViewDimensions + TextLabelMarginTop;
    
    CGFloat rawTextHeight = [self heightForRawTextWithModel:model labelWidth:labelWidth];
    if ([self shouldShowMoreButtonForTextHeight:rawTextHeight model:model]) {
        height += ReadMoreButtonHeight;
    }

    CGFloat textViewHeight = [self heightForTextLabelWithModel:model labelWidth:labelWidth];
    height += textViewHeight;
    
    if (model.photosURLs.count > 1) {
        height += PhotosCarouselHeight;
        height += PhotoViewMarginTop;// + 20;
    } else if (model.photosURLs.count == 1) {
        height += SinglePhotoImageViewHeight;
        height += PhotoViewMarginTop;// + 4;
    }
    
    height += ActionsBarHeight;
    
    return height;
}

+ (BOOL)shouldShowMoreButtonForTextHeight:(CGFloat)textHeight model:(FeedItemCollectionViewModel *)model {
    if (model.textIsExpanded) {
        return NO;
    }
    
    if (textHeight > TextFont.lineHeight * 8) {
        return YES;
    }
    
    return NO;
}

+ (CGFloat)heightForRawTextWithModel:(FeedItemCollectionViewModel *)model labelWidth:(CGFloat)width {
    CGSize textSize = [model.text sizeWithFont:TextFont
                                    constrainedToSize:(CGSize){width, CGFLOAT_MAX}
                                        lineBreakMode:TextLineBreakMode];
    
    CGFloat height = textSize.height;
    
    return height;
}

+ (CGFloat)heightForTextLabelWithModel:(FeedItemCollectionViewModel *)model labelWidth:(CGFloat)width {
    if (!model.text.length) {
        return 0.0;
    }
    
    CGFloat height = [self heightForRawTextWithModel:model labelWidth:width];
    
    if ([self shouldShowMoreButtonForTextHeight:height model:model]) {
        return ceil(TextFont.lineHeight * 6);
    }
    
    return ceil(height);
}

#pragma mark - Misc
- (void)moreButtonTapped:(id)sender {
    self.model.textIsExpanded = YES;
    [self.expansionDelegate feedCellAsksToBeExpanded:self];
}

-(void)feedItemPhotosCarouselInteractionDidStart:(FeedItemPhotosCarousel *)carousel {
    [self endRasterizing];
}

-(void)feedItemPhotosCarouselInteractionDidFinish:(FeedItemPhotosCarousel *)carousel {
    [self beginRasterizing];
}

- (void)beginRasterizing {
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)endRasterizing {
    if (!self.layer.shouldRasterize) {
        return;
    }
    
    self.layer.shouldRasterize = NO;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self beginRasterizing];

    self.singlePhotoImageView.image = nil;
    [self.photosCarousel prepareForReuse];
}

@end
