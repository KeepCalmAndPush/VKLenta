//
//  VKAuthorizationControllerViewController.m
//  BigBookTest
//
//  Created by Андрей Соловьев on 11/11/2018.
//  Copyright © 2018 andrey. All rights reserved.
//

#import "VKAuthorizationController.h"

@interface VKAuthorizationController ()

@property (nonatomic, readwrite) WKWebView *webView;

@end

@implementation VKAuthorizationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _webView = [WKWebView new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:_webView];
}

- (void)beginAuthorization {
    NSString *urlString = @"https://oauth.vk.com/authorize?client_id=7834310&display=page&redirect_uri=https://oauth.vk.com/blank.html&scope=offline,wall,friends&response_type=token&v=5.87";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

@end
