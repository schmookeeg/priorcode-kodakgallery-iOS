//
//  ManagedWebViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge.h"
#import "RootViewController.h"
#import "MBProgressHUD.h"

@interface ManagedWebViewController : RootViewController <WebViewJavascriptBridgeDelegate, MBProgressHUDDelegate> {
    UIWebView *_webView;
    WebViewJavascriptBridge *_bridge;

@private
    NSString *_leftButtonAction;
    NSString *_rightButtonAction;
    MBProgressHUD *_hud;
    NSString *_callbackAction;
    NSString *_urlToLoad;
    BOOL _suppressPageReload;
}

- (void)load:(NSString*)url;
- (void)rightButtonClicked;
- (void)leftButtonClicked;

- (void)sendObject:(NSDictionary *)object;

@property(nonatomic, retain) MBProgressHUD *hud;
@property(nonatomic, retain) NSString *leftButtonAction;
@property(nonatomic, retain) NSString *rightButtonAction;
@property(nonatomic, retain) NSString *callbackAction;
@property(nonatomic, retain) NSString *urlToLoad;

@property(nonatomic) BOOL suppressPageReload;





@end
