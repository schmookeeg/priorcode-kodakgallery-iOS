//
//  DocumentDisplayViewController.h
//  MobileApp
//
//  Created by mikeb on 8/12/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "RootViewController.h"
#import "MBProgressHUD.h"


@interface DocumentDisplayViewController : UIViewController <UIWebViewDelegate>
{

	IBOutlet UILabel *loadingLabel;
	IBOutlet UIActivityIndicatorView *loadingActivityIndiator;

	IBOutlet UIWebView *documentWebView;
	NSString *documentTitle;

	// One of these two values will be nil.  If we have htmlContent
	// we display that.  Otherwise, if we have a url, we load the
	// content from there.
	NSString *htmlContent;
	NSString *url;

	UIButton *_browserBackButton;
	UIButton *_browserForwardButton;
	UIToolbar *_toolbar;

	MBProgressHUD *_hud;
}

- (id)initWithHTML:(NSString *)documentHTML title:(NSString *)titleText;

- (id)initWithEULA:(NSString *)dummyParam;

- (id)initWithCredits:(NSString *)dummyParam;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query;

@end
