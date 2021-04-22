//
//  VKViewController.m
//  BigBookTest
//
//  Created by Андрей Соловьев on 09/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import "VKViewController.h"
#import <WebKit/WebKit.h>
#import "VKEntities.h"
#import "FeedItemActionsBar.h"
#import "FeedCollectionViewModels.h"
#import "FeedItemCollectionViewCell.h"
#import "UIView+Utilities.h"
#import "VKEntities.h"
#import "GradientView.h"
#import "UIColor+Utilities.h"
#import "VKApiInteractor.h"

@interface VKViewControllerFooter : UICollectionReusableView



@end

@implementation VKViewControllerFooter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = UIColor.redColor;
    return self;
}

@end

@interface VKViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FeedItemCellExpansionDelegate>

@property (nonatomic) VKApiInteractor *vkApiInteractor;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) FeedCollectionViewModel *feedModel;

@end

@implementation VKViewController
{
    VKFeed *_feed;
    UIRefreshControl *_refreshControl;
    BOOL _nextLoadingInProgress;
}

- (void)loadView {
    self.view = [[GradientView alloc] initWithTopColor:rgb(0xf7, 0xf9, 0xfa)
                                           bottomColor:rgb(0xeb, 0xed, 0xf0)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    self.title = @"Лента";
    
    [self placeCollectionView];
}

- (void)placeCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 12;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];

    self.collectionView.contentInset = UIEdgeInsetsMake(10, 8, 10, 8);

    [self.view addSubview:self.collectionView];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:FeedItemCollectionViewCell.class forCellWithReuseIdentifier:@"FeedItemCollectionViewCell"];
    [self.collectionView registerClass:VKViewControllerFooter.class forSupplementaryViewOfKind:@"VKViewControllerFooter" withReuseIdentifier:@"VKViewControllerFooter"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    self.collectionView.alwaysBounceVertical = YES;
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(pullToRefreshTriggered) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView sendSubviewToBack:refreshControl];

    _refreshControl = refreshControl;
}

- (void)loadInitialNews {
    [[VKApiInteractor sharedInstance] requestNewsWithCompletion:^(VKFeed *feed, VKApiError *apiError, NSError *networkError) {
        if (apiError || networkError) {
            //Some error
            return;
        }
        self.feedModel = [[FeedCollectionViewModel alloc] initWithVKFeed:feed];
        [self.collectionView reloadData];
        [_refreshControl endRefreshing];
    }];
}


- (void)pullToRefreshTriggered {
    [self loadInitialNews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.feedModel) {
        [self loadInitialNews];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    CGRect frame = self.view.bounds;
     if ([self.view respondsToSelector:@selector(safeAreaInsets)]) {
         frame.origin.y = self.view.safeAreaInsets.top;
    } else {
        frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    }

    frame.size.height -= frame.origin.y;

    self.collectionView.frame = frame;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FeedItemCollectionViewModel *model = [self.feedModel.itemModels objectAtIndex:indexPath.row];
    
    FeedItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedItemCollectionViewCell" forIndexPath:indexPath];
    cell.model = model;
    cell.expansionDelegate = self;
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.feedModel.itemModels.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    FeedItemCollectionViewModel *model = [self.feedModel.itemModels objectAtIndex:indexPath.row];
    
    CGFloat height = [FeedItemCollectionViewCell heightWithModel:model cellWidth:collectionView.width];
    CGFloat width = collectionView.width - collectionView.contentInset.left - collectionView.contentInset.right;
    
    return CGSizeMake(width, height);
}

- (void)feedCellAsksToBeExpanded:(FeedItemCollectionViewCell *)cell {
    NSArray *indexPaths = @[[self.collectionView indexPathForCell:cell]];
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_nextLoadingInProgress) {
        return;
    }

    if (indexPath.row != self.feedModel.itemModels.count - 1) {
        return;
    }
    
    _nextLoadingInProgress = YES;

    [[VKApiInteractor sharedInstance] requestNewsFrom:self.feedModel.nextFrom completion:^(VKFeed *feed, VKApiError *apiError, NSError *networkError) {
        _nextLoadingInProgress = NO;

        if (apiError || networkError) {
            //Some error
            return;
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            FeedCollectionViewModel *model = [[FeedCollectionViewModel alloc] initWithVKFeed:feed];

            NSMutableArray<NSIndexPath *> *paths = [NSMutableArray new];
            for (NSInteger i = 0; i < model.itemModels.count; i++) {
                [paths addObject:[NSIndexPath indexPathForRow:i+self.feedModel.itemModels.count inSection:0]];
            }

            self.feedModel.itemModels = [self.feedModel.itemModels arrayByAddingObjectsFromArray:model.itemModels];
            self.feedModel.nextFrom = model.nextFrom;
            [self.collectionView insertItemsAtIndexPaths:paths];
        });
        
    }];
}

@end
