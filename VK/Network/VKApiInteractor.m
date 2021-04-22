//
//  NetworkInteractor.m
//  BigBookTest
//
//  Created by Андрей Соловьев on 11/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import "VKApiInteractor.h"
#import "VKEntities.h"
#import "VKAuthorizationController.h"
#import <UIKit/UIKit.h>


@interface VKApiInteractor () <WKNavigationDelegate>

@property (nonatomic) NSString *accessToken;
@property (nonatomic) UIViewController *activeAuthorizationNC;
@property (nonatomic, copy) void (^activeAuthorizationCompletion)(void);
@property (nonatomic) NSURLSession *imageCachingSession;

@end


@implementation VKApiInteractor

+ (instancetype)sharedInstance {
    static id sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

@dynamic accessToken;

- (NSString *)accessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
}

- (void)setAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"accessToken"];
}

- (void)requestNewsWithCompletion:(FeedRequestCompletion)completion {
    if (!self.accessToken) {
        [self requestAuthorizationWithCompletion:^{
            [self.activeAuthorizationNC dismissViewControllerAnimated:YES completion:^{
                self.activeAuthorizationNC = nil;
                self.activeAuthorizationCompletion = nil;
            }];
            [self requestNewsWithCompletion:completion];
        }];
        return;
    }
    
    [self requestNewsFrom:nil completion:completion];
}


- (void)requestNewsFrom:(NSString *)from completion:(FeedRequestCompletion)completion {
    from  = from ?: 0;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    static NSString *urlRequestStringTemplate = @"https://api.vk.com/method/newsfeed.get?v=5.87&filters=post&max_photos=10&count=25&start_from=%@&access_token=%@";
    NSString *urlRequestString = [NSString stringWithFormat:urlRequestStringTemplate, from, self.accessToken];
    NSURL *url = [NSURL URLWithString:urlRequestString];

    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession]
                                      dataTaskWithURL:url
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          [self processFeedResponseWithData:data
                                                                   response:response
                                                                      error:error
                                                                 completion:completion];
                                      }];

    [dataTask resume];
}

- (void)processFeedResponseWithData:(NSData *)data
                           response:(NSURLResponse *)response
                              error:(NSError *)error
                         completion:(FeedRequestCompletion)completion {
    NSError *jsonError = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingMutableContainers
                                                             error:&jsonError];

    VKFeed *feed;
    VKApiError *apiError;

    if (result[@"response"]) {
        NSDictionary *resp = result[@"response"];
        feed = [[VKFeed alloc] initWithJSONDictionary:resp];
    } else if (result[@"error"]) {
        NSDictionary *resp = result[@"error"];
        apiError = [[VKApiError alloc] initWithJSONDictionary:resp];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        completion(feed, apiError, error);
    });
}

- (VKAuthorizationController *)meakeReadyToUseAuthorizationController {
    VKAuthorizationController *authVC = [VKAuthorizationController new];
    authVC.title = @"Авторизация";
    authVC.webView.navigationDelegate = self;
    
    return authVC;
}

- (void)requestAuthorizationWithCompletion:(void(^)(void))completion {
    self.activeAuthorizationCompletion = completion;
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    VKAuthorizationController *authVC = [self meakeReadyToUseAuthorizationController];
    [authVC beginAuthorization];
    self.activeAuthorizationNC = [[UINavigationController alloc] initWithRootViewController:authVC];
    
    [rootVC presentViewController:self.activeAuthorizationNC animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSURL *url = navigationResponse.response.URL;
    NSString *token = nil;
    if ([url.host isEqualToString:@"oauth.vk.com"]) {
        NSString *fragment = url.fragment;
        NSArray *fragments = [fragment componentsSeparatedByString:@"&"];
        for (NSString *string in fragments) {
            if ([string hasPrefix:@"access_token="]) {
                token = [string stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
                self.accessToken = token;
                self.activeAuthorizationCompletion();
                
                decisionHandler(WKNavigationResponsePolicyCancel);
                return;
            }
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

+ (NSURLSessionConfiguration *)sessionConfigurationWithExtraHeaders:(NSDictionary *)extraHeaders {
    NSURLSessionConfiguration *conf = NSURLSessionConfiguration.defaultSessionConfiguration.copy;
    conf.URLCache =
    [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024 diskCapacity:200 * 1024 * 1024 diskPath:@"imageCache"];
    conf.HTTPMaximumConnectionsPerHost = 2;
    conf.HTTPShouldUsePipelining = YES;
    conf.HTTPShouldSetCookies = NO;
    conf.HTTPCookieStorage = nil;
    conf.HTTPAdditionalHeaders = extraHeaders.copy;
    return conf;
}

- (NSURLSession *)imageCachingSession {
    if (!_imageCachingSession) {
        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration.copy;
        configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        configuration.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:512 * 1024 * 1024
                                                               diskCapacity:1024 * 1024 * 1024
                                                                   diskPath:@"imageCache"];
        
        _imageCachingSession = [NSURLSession sessionWithConfiguration:configuration];
    }
    
    return _imageCachingSession;
}

- (void)loadImageWithURL:(NSURL *)url completion:(ImageRequestCompletion)completion {
    NSURLSessionDataTask *downloadPhotoTask = [self.imageCachingSession
                                               dataTaskWithURL:url completionHandler:^(NSData * _Nullable data,
                                                                                       NSURLResponse * _Nullable response,
                                                                                       NSError * _Nullable error) {
                                                   if (error) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           completion(nil, url, error);
                                                       });
                                                       return;
                                                   }

                                                   UIImage *image = [UIImage imageWithData:data];
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       completion(image, url, error);
                                                   });
                                               }];
    
    [downloadPhotoTask resume];
}

@end
