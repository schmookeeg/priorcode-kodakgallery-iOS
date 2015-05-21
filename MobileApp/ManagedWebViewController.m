//
//  ManagedWebViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Three20/Three20.h>
#import "ManagedWebViewController.h"
#import "AbstractModel.h"

@implementation ManagedWebViewController

@synthesize hud = _hud;
@synthesize leftButtonAction = _leftButtonAction;
@synthesize rightButtonAction = _rightButtonAction;
@synthesize callbackAction = _callbackAction;
@synthesize urlToLoad = _urlToLoad;
@synthesize suppressPageReload = _suppressPageReload;


- (id)init {
    self = [super init];

    if (self) {
        self.suppressPageReload = NO;
    }

    return self;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        @try
        {
            _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            _hud.delegate = self;
            _hud.removeFromSuperViewOnHide = YES;
            [self.navigationController.view addSubview:_hud];
        }
        @catch ( NSException *exception )
        {
            // Might get an exception here if the view is popped (and therefore nil) before
            // the hud has a chance to be created.  If that's the case, just ignore it.
        }
    }

    return _hud;
}

- (void)hudWasHidden {
    TT_RELEASE_SAFELY(_hud);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _webView.autoresizesSubviews = YES;
    _webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);

    _bridge = [[WebViewJavascriptBridge alloc] init];

    _bridge.delegate = self;
    _webView.delegate = _bridge;

    [self.view addSubview:_webView];
}


- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedObject:(NSDictionary *)object fromWebView:(UIWebView *)webView {
    NSString *command = [object objectForKey:@"command"];
    NSString *value = [object objectForKey:@"value"];

    if ([value isKindOfClass:[NSNull class]]) {
        value = nil;
    }

    BOOL enabled = [[object objectForKey:@"enabled"] isEqualToString:@"true"];

    // standard other params: value, callback, enabled
    if ([command isEqualToString:@"loadPage"]) {
        [self load:value];
    }
    else if ([command isEqualToString:@"showHUD"]) {
        if (value != nil) {
            self.hud.labelText = value;
        } else {
            self.hud.labelText = @"Loading..";
        }

        [self.hud show:YES];
    }
    else if ([command isEqualToString:@"hideHUD"]) {
        [self.hud hide:YES];
    }
    else if ([command isEqualToString:@"enableLeftButton"]) {
        self.navigationItem.leftBarButtonItem.enabled = enabled;
    }
    else if ([command isEqualToString:@"enableRightButton"]) {
        self.navigationItem.rightBarButtonItem.enabled = enabled;
    }
    else if ([command isEqualToString:@"rightButtonTitle"]) {
        NSString *style = [object objectForKey:@"style"];
        UIBarButtonItemStyle buttonStyle = UIBarButtonItemStylePlain;
        if ([style isEqualToString:@"done"]) {
            buttonStyle = UIBarButtonItemStyleDone;
        }

        if (value != nil) {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:value style:buttonStyle target:self action:@selector(rightButtonClicked)] autorelease];
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    else if ([command isEqualToString:@"rightButtonAction"]) {
        self.rightButtonAction = value;

    }
    else if ([command isEqualToString:@"leftButtonTitle"]) {
        NSString *style = [object objectForKey:@"style"];
        UIBarButtonItemStyle buttonStyle = UIBarButtonItemStylePlain;
        if ([style isEqualToString:@"done"]) {
            buttonStyle = UIBarButtonItemStyleDone;
        }

        if (value != nil) {
            if ([style isEqualToString:@"back"]) {
                UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
                [a1 setFrame:CGRectMake(0.0f, 0.0f, 52.0f, 32.0f)];
                [a1 addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
                [a1 setImage:[UIImage imageNamed:kAssetDarkBackButtonIcon] forState:UIControlStateNormal];
                UIBarButtonItem *random = [[[UIBarButtonItem alloc] initWithCustomView:a1] autorelease];

                self.navigationItem.leftBarButtonItem = random;
            } else {
                self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:value style:buttonStyle target:self action:@selector(leftButtonClicked)] autorelease];
            }
        } else {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    else if ([command isEqualToString:@"leftButtonAction"]) {
        self.leftButtonAction = value;
    }
    else if ([command isEqualToString:@"title"]) {
        self.navigationController.navigationBar.topItem.title = value;
    }
    else if ([command isEqualToString:@"showNavigationBar"]) {
        [self.navigationController setNavigationBarHidden:!enabled];
    }
    else if ([command isEqualToString:@"showTabBar"]) {
        [self.tabBarController.tabBar setHidden:!enabled];
    }
    else if ([command isEqualToString:@"openExternalURL"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:value]];
    }
    else if ([command isEqualToString:@"apiVersion"]) {
        [self sendObject:[NSDictionary dictionaryWithKeysAndObjects:
                @"command", @"apiVersion",
                @"value", kJSWebBridgeVersion,
                nil]];
    }
    else if ([command isEqualToString:@"trackPageView"]) {
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:value];
    }
    else if ([command isEqualToString:@"showStandardError"]) {
        [AbstractModel uncaughtFailure];
    }
}

- (void)load:(NSString *)url {

    self.hud.labelText = @"Loading..";
    [self.hud show:YES];

    _webView.hidden = YES;
    [_webView stopLoading];

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.hud hide:YES];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [AbstractModel uncaughtFailure];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _webView.hidden = NO;
    [self.hud hide:YES];
}

- (void)rightButtonClicked {
    if (self.rightButtonAction) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"rightButtonClicked" forKey:@"command"]];
    }
}

- (void)leftButtonClicked {
    if (self.leftButtonAction) {
        [self sendObject:[NSDictionary dictionaryWithObject:@"leftButtonClicked" forKey:@"command"]];
    }
}

- (void)sendObject:(NSDictionary *)object {
    [_bridge sendObject:object toWebView:_webView];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.callbackAction) {
        [self sendObject:[NSDictionary dictionaryWithObject:self.callbackAction forKey:@"command"]];
        self.callbackAction = nil;
    }

    else if (self.urlToLoad) {
        [self load:self.urlToLoad];
    }
            // we don't want to always refresh unless we tab out
    else if (!self.suppressPageReload) {
        [self load:_webView.request.URL.absoluteString];
    }

    self.urlToLoad = nil;
    self.suppressPageReload = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self sendObject:[NSDictionary dictionaryWithObject:@"viewClosing" forKey:@"command"]];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_webView setDelegate:nil];
    [_webView stopLoading];
    [_webView release];
    [_bridge release];
    [_hud release];

    [_leftButtonAction release];
    [_rightButtonAction release];
    [_callbackAction release];
    [_urlToLoad release];

	[super dealloc];
}

@end
