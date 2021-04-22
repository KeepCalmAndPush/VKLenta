//
//  FeedItemCollectionViewModel.h
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class FeedItemActionsBarModel;
@class FeedItemCollectionViewModel;
@class VKFeed;

@interface FeedCollectionViewModel : NSObject

- (instancetype)initWithVKFeed:(VKFeed *)feed;

@property (nonatomic) NSArray<FeedItemCollectionViewModel *> *itemModels;
@property (nonatomic, copy) NSString *nextFrom;

@end

@interface FeedItemCollectionViewModel : NSObject
@property (nonatomic) NSURL *userAvatarImageURL;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *dateFormatted;
@property (nonatomic) NSArray<NSURL *> *photosURLs;
@property (nonatomic) FeedItemActionsBarModel *actionsBarModel;

@property (nonatomic, copy) NSString *text;
@property (nonatomic) BOOL textIsExpanded;
@end


@interface FeedItemActionsBarModel : NSObject
@property (nonatomic, copy) NSString *likesCountFormatted;
@property (nonatomic, copy) NSString *commentsCountFormatted;
@property (nonatomic, copy) NSString *repostsCountFormatted;
@property (nonatomic, copy) NSString *viewsCountFormatted;
@end
