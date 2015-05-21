//
//  DocumentDisplayViewController.m
//  MobileApp
//
//  Created by Dev on 8/12/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "DocumentDisplayViewController.h"


@implementation DocumentDisplayViewController

#pragma mark Init

- (id)initWithHTML:(NSString *)documentHTML title:(NSString *)titleText
{
	self = [super init];
	if ( self )
	{
		documentTitle = titleText;
		htmlContent = documentHTML;
	}
	return self;
}

- (id)initWithEULA:(NSString *)dummyParam
{

	NSString *path = [[NSBundle mainBundle] pathForResource:@"AppsEULA" ofType:@"html"];
	NSError *error = nil;
	NSString *html = [NSString stringWithContentsOfFile:path
											   encoding:NSUTF8StringEncoding
												  error:&error];
	if ( error == nil )
	{
		self = [self initWithHTML:html title:@"License Agreement"];
	}
	else
	{
		self = [super init];
	}

	return self;
}

- (id)initWithCredits:(NSString *)dummyParam
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"];
	NSError *error = nil;
	NSString *html = [NSString stringWithContentsOfFile:path
											   encoding:NSUTF8StringEncoding
												  error:&error];
	if ( error == nil )
	{
		self = [self initWithHTML:html title:@"Credits"];
	}
	else
	{
		self = [super init];
	}

	return self;
}

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
	self = [super init];
	if ( self )
	{
		// TRICKY Pull the url from the dictionary query that was supplied with the
		// action that brought us here.
		url = [query objectForKey:@"url"];
		documentTitle = [query objectForKey:@"title"];
	}

	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		return self;
	}
	return self;
}



#pragma mark - Memory Management

- (void)dealloc
{
	TT_RELEASE_SAFELY(_browserBackButton);
	TT_RELEASE_SAFELY(_browserForwardButton);
	TT_RELEASE_SAFELY(_toolbar);
	TT_RELEASE_SAFELY(loadingLabel);
	TT_RELEASE_SAFELY(loadingActivityIndiator);
	TT_RELEASE_SAFELY(_hud);
	TT_RELEASE_SAFELY(documentWebView);
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

#pragma mark

- (void)showLoadingActivity
{
	loadingLabel.hidden = NO;
	loadingActivityIndiator.hidden = NO;
	[loadingActivityIndiator startAnimating];
}

- (void)hideLoadingActivity
{
	loadingLabel.hidden = YES;
	loadingActivityIndiator.hidden = YES;
	[loadingActivityIndiator stopAnimating];
}

- (void)setupToolbar
{
	_browserForwardButton =
			[[UIBarButtonItem alloc] initWithImage:TTIMAGE(@"bundle://Three20.bundle/images/nextIcon.png") style:UIBarButtonItemStylePlain
											target:self
											action:@selector(browserForward)];
	_browserBackButton =
			[[UIBarButtonItem alloc]                                    initWithImage:
					TTIMAGE(@"bundle://Three20.bundle/images/previousIcon.png") style:UIBarButtonItemStylePlain
																			   target:self
																			   action:@selector(browserBack)];
	UIBarItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
			UIBarButtonSystemItemFlexibleSpace                        target:nil action:nil] autorelease];

	CGRect screenFrame = self.view.bounds;

	_toolbar = [[UIToolbar alloc] initWithFrame:
			CGRectMake( 0, screenFrame.size.height - TT_ROW_HEIGHT,
					screenFrame.size.width, TT_ROW_HEIGHT )];
	_toolbar.barStyle = UIBarStyleBlackTranslucent;
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_toolbar.items = [NSArray arrayWithObjects:
			space, _browserBackButton, space, _browserForwardButton, space, nil];
	[self.view addSubview:_toolbar];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Check to see if we have a remote url to load content from
	if ( url != nil )
	{
		NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
		[documentWebView loadRequest:urlRequest];

		//[self showLoadingActivity];
	}
	else // Load local htmlContent
	{
		NSString *contentPath = [[NSBundle mainBundle] bundlePath];
		NSURL *baseURL = [NSURL fileURLWithPath:contentPath];
		[documentWebView loadHTMLString:htmlContent baseURL:baseURL];
	}

	self.title = documentTitle;
	[self setupToolbar];

	_hud = [[MBProgressHUD alloc] initWithView:self.view];
	[self.navigationController.view addSubview:_hud];
	_hud.labelText = @"Loading...";

}

/*
- (void)viewDidUnload
{
	TT_RELEASE_SAFELY(documentTitle);
	TT_RELEASE_SAFELY(url);
	TT_RELEASE_SAFELY(htmlContent);
	[super viewDidUnload];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// [self showLoadingActivity];
	[_hud show:YES];
	[_browserBackButton setEnabled:NO];
	[_browserForwardButton setEnabled:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//[self hideLoadingActivity];
	[_hud hide:YES];
	[_browserBackButton setEnabled:[documentWebView canGoBack]];
	[_browserForwardButton setEnabled:[documentWebView canGoForward]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// TODO Show an error message that the remote document couldn't load?

	[self hideLoadingActivity];
}

- (void)browserBack
{
	[documentWebView goBack];
}

- (void)browserForward
{
	[documentWebView goForward];

}

@end
