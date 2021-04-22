//
//  NetworkInteractor.h
//  BigBookTest
//
//  Created by Андрей Соловьев on 11/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VKFeed;
@class VKApiError;
@class UIImage;

typedef void (^FeedRequestCompletion)(VKFeed *feed, VKApiError *apiError, NSError *networkError);
typedef void (^ImageRequestCompletion)(UIImage *image, NSURL *url, NSError *networkError);

@interface VKApiInteractor : NSObject

+ (instancetype)sharedInstance;

- (void)requestNewsWithCompletion:(FeedRequestCompletion)completion;
- (void)requestNewsFrom:(NSString *)from completion:(FeedRequestCompletion)completion;

- (void)loadImageWithURL:(NSURL *)url completion:(ImageRequestCompletion)completion;

@end
