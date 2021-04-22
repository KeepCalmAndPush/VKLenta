//
//  FeedItemCollectionViewCell.h
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeedItemCollectionViewModel;
@class FeedItemCollectionViewCell;

@protocol FeedItemCellExpansionDelegate <NSObject>

- (void)feedCellAsksToBeExpanded:(FeedItemCollectionViewCell *)cell;

@end

@interface FeedItemCollectionViewCell : UICollectionViewCell

@property (nonatomic) FeedItemCollectionViewModel *model;
@property (nonatomic, weak) id<FeedItemCellExpansionDelegate> expansionDelegate;

+ (CGFloat)heightWithModel:(FeedItemCollectionViewModel *)model cellWidth:(CGFloat)width;

@end
