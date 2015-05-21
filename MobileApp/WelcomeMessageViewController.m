//
//  WelcomeMessageViewController.m
//  MobileApp
//
//  Created by Dev on 9/14/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "WelcomeMessageViewController.h"
#import <Three20/Three20.h>
#import "IncomingURLHandler.h"
#import "MobileAppAppDelegate.h"
#import "UIColor+Colors.h"

NSString *const kGroupWelcomePageUrl = @"/gallery/mobile/app/groupWelcome.jsp";
NSString *const kFriendWelcomePageUrl = @"/gallery/mobile/app/friendsWelcome.jsp";
NSString *const kGeneralWelcomePageUrl = @"/gallery/mobile/app/generalWelcome.jsp";

@implementation WelcomeMessageViewController
@synthesize url, goActionUrl, incomingUrl, ownerName, albumTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		UIImage *barLogo = [UIImage imageNamed:kAssetLogo];
		UIImageView *barLogoView = [[[UIImageView alloc] initWithImage:barLogo] autorelease];
		self.navigationController.navigationBarHidden = NO;
		self.navigationItem.titleView = barLogoView;
		UIView *dummyUIView = [[UIView alloc] init];
		UIBarButtonItem *dummyBackButton = [[UIBarButtonItem alloc] initWithCustomView:dummyUIView];
		[dummyUIView release];
		self.navigationItem.leftBarButtonItem = dummyBackButton;
		[dummyBackButton release];
	}
	return self;
}

- (void)parseIncomingUrl
{
	NSArray *parameters = [[self.incomingUrl query] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
	NSMutableDictionary *keyValueParm = [NSMutableDictionary dictionary];
	for ( NSUInteger i = 0; i < [parameters count]; i = i + 2 )
	{
		[keyValueParm setObject:[parameters objectAtIndex:i + 1] forKey:[parameters objectAtIndex:i]];
	}

	if ( [keyValueParm objectForKey:@"groupId"] != nil )
	{
		self.url = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kGroupWelcomePageUrl];
	}
	else
	{
		self.url = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kFriendWelcomePageUrl];
	}

	self.ownerName = [keyValueParm objectForKey:@"ownerName"];
	if ( self.ownerName == nil )
	{
		self.ownerName = @"";
	}
	self.albumTitle = [keyValueParm objectForKey:@"albumTitle"];
	if ( self.albumTitle == nil )
	{
		self.albumTitle = @"";
	}

	self.url = [NSString stringWithFormat:@"%@?ownerName=%@&albumTitle=%@", self.url, self.ownerName, self.albumTitle];
}

- (id)initWithIncomingUrl:(NSURL *)inboundUrl
{
	self = [super init];
	if ( self )
	{
		self.incomingUrl = inboundUrl;
		[self parseIncomingUrl];

	}
	return self;

}

- (id)initWithUrl:(NSString *)welcomeUrl actionUrl:(NSString *)actionURL
{
	self = [super init];
	if ( self )
	{
		self.url = welcomeUrl;
		self.goActionUrl = actionURL;
	}
	return self;
}

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
	self = [super init];
	if ( self )
	{
		if ( query == nil )
		{
			// If no dictionary just assume they want the general welcome screen
			self.url = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kGeneralWelcomePageUrl];
		}
		else
		{
			// TRICKY Pull the url from the dictionary query that was supplied with the
			// action that brought us here.
			self.incomingUrl = [query objectForKey:@"incomingUrl"];
			[self parseIncomingUrl];
		}
	}

	return self;
}

- (void)dealloc
{
	[welcomeWebView release];
	[goButton release];
	[url release];
	[goActionUrl release];
	[incomingUrl release];
	[ownerName release];
	[albumTitle release];

	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)applyGradientToBottomButtonArea
{
	// Initialize the gradient layer
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];

    // Create a bounding area for the empty space at the bottom
    CGRect bounds = self.view.bounds;
    const int kBottomAreaHeight = 69;
    CGRect bottomButtonAreaBounds = CGRectMake( 0, 0, bounds.size.width, kBottomAreaHeight);
    gradientLayer.bounds = bottomButtonAreaBounds;
    // Place layer at the bottom of the view
    gradientLayer.position = CGPointMake( CGRectGetMidX( bounds ), bounds.size.height - ( kBottomAreaHeight / 2 ) );

    gradientLayer.colors = [UIColor titleBarGradientColors];
	gradientLayer.locations = [UIColor titleBarGradientLocations];

	[self.view.layer insertSublayer:gradientLayer atIndex:0];
	[gradientLayer release];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];

	welcomeWebView.delegate = self;

    [self applyGradientToBottomButtonArea];

	// Check to see if we have a remote url to load content from
	if ( self.url != nil )
	{
		NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
		[welcomeWebView loadRequest:urlRequest];
	}
	else
	{
		NSLog( @"No URL found for WelcomeMessageViewController" );
	}

	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Welcome Message:View"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidUnload
{
	[welcomeWebView release];
	welcomeWebView = nil;
	[goButton release];
	goButton = nil;
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

- (IBAction)goButtonTouched:(id)sender
{
	[[self navigationController] dismissModalViewControllerAnimated:YES];

    if ( self.incomingUrl != nil )
	{
		// Join and navigate to the correct album in the event we were passed an incomingUrl
		MobileAppAppDelegate *appDelegate = (MobileAppAppDelegate *) [[UIApplication sharedApplication] delegate];
		appDelegate.incomingURLHandler = [[[IncomingURLHandler alloc] initWithURL:self.incomingUrl] autorelease];
	}

	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Welcome Message:Get Started"];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	// If user taps a link in our document view launch that link in Mobile Safari instead of our document view as we don't have back buttons
	if ( navigationType == UIWebViewNavigationTypeLinkClicked )
	{
		NSURL *linkUrl = [request URL];
		[[UIApplication sharedApplication] openURL:linkUrl];
		return NO;
	}
	return YES;
}

- (BOOL)hidesBottomBarWhenPushed{
	return YES;
}

@end
