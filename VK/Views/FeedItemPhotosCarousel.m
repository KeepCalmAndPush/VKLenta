//
//  FeedItemPhotosCarousel.m
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import "FeedItemPhotosCarousel.h"
#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"
#import "VKApiInteractor.h"

@interface FeedItemPhotosCarouselCell : UICollectionViewCell

@property (nonatomic) NSURL *url;
@property (nonatomic) UIImageView *imageView;

@end

@implementation FeedItemPhotosCarouselCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self placeImageView];
    }
    
    return self;
}

- (void)placeImageView {
    self.imageView = [UIImageView new];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    
    [self.contentView addSubview:self.imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end

@interface FeedItemPhotosCarousel() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) UIView *separator;

@end

@implementation FeedItemPhotosCarousel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self placeCollectionView];
        [self placePageControl];
        [self placeSeparator];
    }
    
    return self;
}

- (void)placeCollectionView {
    UICollectionViewFlowLayout *lay = [[UICollectionViewFlowLayout alloc] init];
    lay.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    lay.minimumLineSpacing = 5;
    lay.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:lay];
    self.collectionView.opaque = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:NSClassFromString(@"FeedItemPhotosCarouselCell") forCellWithReuseIdentifier:@"FeedItemPhotosCarouselCell"];
}

- (void)placePageControl {
    self.pageControl = [UIPageControl new];
    self.pageControl.pageIndicatorTintColor = [rgb(0x51, 0x81, 0xb8) colorWithAlphaComponent:0.32];
    self.pageControl.currentPageIndicatorTintColor = rgb(0x51, 0x81, 0xb8);
    [self addSubview:self.pageControl];
}

- (void)placeSeparator {
    self.separator = [UIView new];
    self.separator.backgroundColor = rgb(0xd7, 0xd8, 0xd9);
    [self addSubview:self.separator];
}

- (void)setPhotosURLs:(NSArray<NSURL *> *)photosURLs {
    _photosURLs = photosURLs;
    
    [self.collectionView reloadData];
    self.pageControl.numberOfPages = self.photosURLs.count;
    self.pageControl.currentPage = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutCollectionView];
    [self layoutPageControl];
    [self layoutSeparator];
}

- (void)layoutCollectionView {
    CGRect collectionViewFrame = self.bounds;
    collectionViewFrame.size.height = 250;
    
    self.collectionView.frame = collectionViewFrame;
}

- (void)layoutPageControl {
    [self.pageControl sizeForNumberOfPages:self.photosURLs.count];
    CGRect pageControlFrame = self.pageControl.frame;
    pageControlFrame.origin.x = (self.width - pageControlFrame.size.width) / 2;
    pageControlFrame.origin.y = self.collectionView.height + 16;
    pageControlFrame.size.width = MIN(pageControlFrame.size.width, self.width - 24);
    pageControlFrame.size.height = 7;
    
    self.pageControl.frame = CGRectIntegral(pageControlFrame);
}

- (void)layoutSeparator {
    CGFloat height = 1 / [UIScreen mainScreen].scale;
    self.separator.frame = CGRectMake(12, self.height - height, self.width - 2 * 12, height);
}

#pragma mark - CollectionView Delegate

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FeedItemPhotosCarouselCell *cell = (FeedItemPhotosCarouselCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FeedItemPhotosCarouselCell" forIndexPath:indexPath];
    
    NSURL *urlAtIndex = [self.photosURLs objectAtIndex:indexPath.row];
    
    [VKApiInteractor.sharedInstance loadImageWithURL:urlAtIndex completion:^(UIImage *image, NSURL *url, NSError *networkError) {
        if ([url isEqual:urlAtIndex]) {
            if (image) {
                cell.imageView.image = image;
            }
        }
    }];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosURLs.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 250.0;
    CGFloat width = ceil(collectionView.width * 335.0 / 360.0);
    
    return CGSizeMake(width, height);
}

#pragma mark - Touch handling
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.carouselDelegate feedItemPhotosCarouselInteractionDidStart:self];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.carouselDelegate feedItemPhotosCarouselInteractionDidFinish:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self selectApproproatePage];
}

- (void)selectApproproatePage {
    NSArray<UICollectionViewCell *> *visibleCells = self.collectionView.visibleCells;
    if (!visibleCells.count) {
        return;
    }

    CGPoint offset = self.collectionView.contentOffset;
    CGRect visibleRect;
    visibleRect.size = self.collectionView.size;
    visibleRect.origin = offset;

    if (visibleCells.count == 1) {
        [self selectPageForCell:visibleCells.firstObject];
        return;
    }
    
    UICollectionViewCell *firstCell = visibleCells.firstObject;
    UICollectionViewCell *secondCell = visibleCells[1];
    
    CGRect firstRect = CGRectIntersection(firstCell.frame, visibleRect);
    CGRect secondRect = CGRectIntersection(secondCell.frame, visibleRect);
    
    if (firstRect.size.width >= secondRect.size.width) {
        [self selectPageForCell:firstCell];
    } else {
        [self selectPageForCell:secondCell];
    }
}

- (void)selectPageForCell:(UICollectionViewCell *)cell {
    NSInteger index = [self.collectionView indexPathForCell:cell].row;
    self.pageControl.currentPage = index;
}

- (void)prepareForReuse {
    self.photosURLs = @[];

    [self.collectionView reloadData];
}

@end

