//
//  FeedItemCollectionViewModel.m
//  BigBookTest
//
//  Created by Андрей Соловьев on 10/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import "FeedCollectionViewModels.h"
#import "VKEntities.h"

@implementation FeedCollectionViewModel : NSObject

- (instancetype)initWithVKFeed:(VKFeed *)feed {
    self = [super init];
    
    if (self) {
        [self fillItemModelsWithFeed:feed];
        self.nextFrom = feed.next_from;
    }
    
    return self;
}

- (void)fillItemModelsWithFeed:(VKFeed *)feed {
    NSMutableArray *itemsModels = [NSMutableArray new];
    
    for (VKFeedItem *item in feed.items) {
        [itemsModels addObject:[self modelWithItem:item inFeed:feed]];
    }
    
    self.itemModels = itemsModels;
}

- (FeedItemCollectionViewModel *)modelWithItem:(VKFeedItem *)item inFeed:(VKFeed *)feed {
    FeedItemCollectionViewModel *model = [FeedItemCollectionViewModel new];
    
    NSMutableArray<NSURL *> *urls = [NSMutableArray new];
    for (VKAttachment *attachment in item.attachments) {
        VKPhoto *photo = attachment.photo;
        for (VKPhotoSize *size in photo.sizes) {
            if ([size.type isEqualToString:@"r"]) {
                [urls addObject:[NSURL URLWithString:size.url]];
            }
        }
    }
    
    model.photosURLs = urls;
    
    FeedItemActionsBarModel *mo = [FeedItemActionsBarModel new];
    mo.likesCountFormatted = [self formatNumber:item.likes.count];
    mo.commentsCountFormatted = [self formatNumber:item.comments.count];
    mo.repostsCountFormatted = [self formatNumber:item.reposts.count];
    mo.viewsCountFormatted = [self formatNumber:item.views.count];
    model.actionsBarModel = mo;
    
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = NSDateFormatter.new;
        formatter.dateFormat = @"dd MMM HH:mm";
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:item.date.integerValue];
    model.dateFormatted = [formatter stringFromDate:date];
    NSInteger absValue = labs(item.source_id.integerValue);
    
    if (item.source_id.integerValue < 0) {
        
        for (VKGroupInfo *group in feed.groups) {
            if (group.id.integerValue == absValue) {
                model.userName = group.name;
                model.userAvatarImageURL = [NSURL URLWithString:group.photo_100];
                break;
            }
        }
    } else {
        for (VKUserInfo *user in feed.profiles) {
            if (user.id.integerValue == absValue) {
                model.userName = [NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name];
                model.userAvatarImageURL = [NSURL URLWithString:user.photo_100];
                break;
            }
        }
    }
    
    model.text = item.text;
    
    return model;
}

- (NSString *)formatNumber:(NSNumber *)nsnumber {
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    NSInteger number = nsnumber.integerValue;
    
    if (number > 1000000000) {
        [numFormatter setMultiplier:@0.000000001];
        [numFormatter setPositiveFormat:@"0G"];
    } else if (number > 1000000) {
        [numFormatter setMultiplier:@0.000001];
        [numFormatter setPositiveFormat:@"0M"];
    } else if (number > 1000) {
        [numFormatter setMultiplier:@0.001];
        [numFormatter setPositiveFormat:@"0К"];
    } else {
        [numFormatter setMultiplier:@1];
    }
    
    NSString *formattedNumber = [numFormatter stringFromNumber:[NSNumber numberWithInteger:number]];
    return formattedNumber;
}

@end

@implementation FeedItemCollectionViewModel
@end

@implementation FeedItemActionsBarModel
@end
