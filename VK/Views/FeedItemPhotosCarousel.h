//
//  FeedItemPhotosCarousel.h
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedItemPhotosCarousel;

@protocol FeedItemPhotosCarouselDelegate <NSObject>

-(void)feedItemPhotosCarouselInteractionDidStart:(FeedItemPhotosCarousel *)carousel;
-(void)feedItemPhotosCarouselInteractionDidFinish:(FeedItemPhotosCarousel *)carousel;

@end

@interface FeedItemPhotosCarousel : UIView

@property (nonatomic) NSArray<NSURL *> *photosURLs;
@property (nonatomic) id<FeedItemPhotosCarouselDelegate> carouselDelegate;

- (void)prepareForReuse;

@end
