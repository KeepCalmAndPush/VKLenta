//
//  VKAuthorizationControllerViewController.h
//  BigBookTest
//
//  Created by Андрей Соловьев on 11/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface VKAuthorizationController : UIViewController

@property (nonatomic, readonly) WKWebView *webView;

- (void)beginAuthorization;

@end
