//
//  ShopViewController.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "ShopViewController.h"
#import "SelectAlbumViewController.h"
#import "UserModel.h"
#import "CartModel.h"
#import "Assets.h"

@interface ShopViewController ()
- (void)shopPhotoGiftsAction:(id)sender;
@end

@implementation ShopViewController

#pragma mark init / dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		self.title = @"Shop";
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Shop" image:[UIImage imageNamed:@"PrintsTab.png"] tag:0] autorelease];        
	}
	return self;
}


- (void)dealloc
{
	[shopPrints release];
	[shopPhotoGift release];
	[signInAlertView release];
    
    [makePrintsLabel release];
    [printsPriceLabel release];
    
    [makeMagnetsLabel release];
    [magnetPriceLabel release];
    
	[super dealloc];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.

	self.navigationItem.title = @"make*(stuff)";
    
    // Setup the logo at the top
    UIImage *logo = [UIImage imageNamed:kAssetMakeStuffLogo];
    UIImageView *logoView = [[[UIImageView alloc] initWithImage:logo] autorelease];
    self.navigationItem.titleView = logoView;
    
    // "Draw" horizontal rule in the middle of the view
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake( 10, 182, self.view.bounds.size.width - 20, 1 )];
    lineView.backgroundColor = [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1];
    [self.view addSubview:lineView];
    [lineView release];

	// ----------------------------------------------------------------
	// Configure the font colors in the make* headers
	// ----------------------------------------------------------------

	// Font and size
	UIFont *font = [UIFont systemFontOfSize:23.0];
	CTFontRef fontRef = CTFontCreateWithName( (CFStringRef) font.fontName, font.pointSize, nil );

    NSMutableAttributedString *makePrintsString = [[NSMutableAttributedString alloc] initWithString:@"make*(prints)"];
    NSRange makePrintsRange = NSMakeRange( 0, makePrintsString.length );

	// Font and size
	[makePrintsString addAttribute:(NSString *) kCTFontAttributeName value:(id) fontRef range:makePrintsRange];

	// Text color
	[makePrintsString addAttribute:(NSString *) kCTForegroundColorAttributeName
							 value:(id) [UIColor whiteColor].CGColor
							 range:makePrintsRange];

	// Green color for the "prints" text
    UIColor *greenColor = [UIColor colorWithRed:0x70/255.0 green:0xFF/255.0 blue:0x24/255.0 alpha:1];
	[makePrintsString addAttribute:(NSString *) kCTForegroundColorAttributeName
							 value:(id) greenColor.CGColor
							 range:NSMakeRange( 6, 6 )];
	

	makePrintsLabel.text = makePrintsString;
	[makePrintsString release];

	// ----------------------------------------------------------------

	NSMutableAttributedString *makeMagnetsString = [[NSMutableAttributedString alloc] initWithString:@"make*(magnets)"];
    NSRange makeMagnetsRange = NSMakeRange( 0, makeMagnetsString.length );
    
	[makeMagnetsString addAttribute:(NSString *) kCTFontAttributeName value:(id) fontRef range:makeMagnetsRange];

	// Text color
	[makeMagnetsString addAttribute:(NSString *) kCTForegroundColorAttributeName
							  value:(id) [UIColor whiteColor].CGColor
							  range:makeMagnetsRange];

    // Pink color for the "prints" text
    UIColor *pinkColor = [UIColor colorWithRed:0xFF/255.0 green:0x36/255.0 blue:0xD9/255.0 alpha:1];
	[makeMagnetsString addAttribute:(NSString *) kCTForegroundColorAttributeName
							  value:(id) pinkColor.CGColor
							  range:NSMakeRange( 6, 7 )];
    
	makeMagnetsLabel.text = makeMagnetsString;
	[makeMagnetsString release];
    
    CFRelease( fontRef );
    
    // ----------------------------------------------------------------
	// Configure pricing labels
	// ----------------------------------------------------------------
    
    // Font and size
	font = [UIFont systemFontOfSize:14.0];
	fontRef = CTFontCreateWithName( (CFStringRef) font.fontName, font.pointSize, nil );

    
    NSMutableAttributedString *printsPricingString = [[NSMutableAttributedString alloc] initWithString:@"From 20¢"];
    NSRange printsPricingRange = NSMakeRange( 0, printsPricingString.length );
    
    [printsPricingString addAttribute:(NSString *) kCTFontAttributeName value:(id) fontRef range:printsPricingRange];
    
    // Text color
	[printsPricingString addAttribute:(NSString *) kCTForegroundColorAttributeName
                                 value:(id) [UIColor whiteColor].CGColor
                                 range:printsPricingRange];
    
    printsPriceLabel.text = printsPricingString;
    [printsPricingString release];

    // ----------------------------------------------------------------

    NSMutableAttributedString *magnetsPricingString = [[NSMutableAttributedString alloc] initWithString:@"$4.99 $3.99 ea + Free Shipping"];
    NSRange magnetsPricingRange = NSMakeRange( 0, magnetsPricingString.length );
    
    [magnetsPricingString addAttribute:(NSString *) kCTFontAttributeName value:(id) fontRef range:magnetsPricingRange];
    
    // Text color
	[magnetsPricingString addAttribute:(NSString *) kCTForegroundColorAttributeName
							  value:(id) [UIColor whiteColor].CGColor
							  range:magnetsPricingRange];
    
    // Strike-through the original price
    [magnetsPricingString addAttribute:kTTTStrikeOutAttributeName
                                 value:[NSNumber numberWithBool:YES]
                                 range:NSMakeRange( 0, 5 )];

    // Red for sale price and free shipping
    [magnetsPricingString addAttribute:(NSString *) kCTForegroundColorAttributeName
                                 value:(id) [UIColor redColor].CGColor
                                 range:NSMakeRange( 6, 24 )];


    magnetPriceLabel.numberOfLines = 1;
    magnetPriceLabel.lineBreakMode = UILineBreakModeWordWrap;
    magnetPriceLabel.adjustsFontSizeToFitWidth = NO;
    
    magnetPriceLabel.text = magnetsPricingString;
    [magnetsPricingString release];
    
    CFRelease( fontRef );
    
	// ----------------------------------------------------------------
	// Stylize the "Shop" buttons
	// ----------------------------------------------------------------

	UIColor *highColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	UIColor *lowColor = [UIColor colorWithRed:133.0 / 255.0 green:133.0 / 255.0 blue:133.0 / 255.0 alpha:1.0];
	UIColor *borderColor = [UIColor colorWithRed:238.0 / 255.0 green:238.0 / 255.0 blue:238.0 / 255.0 alpha:1.0];
	UIColor *textColor = [UIColor blackColor];
	UIColor *textShadowColor = [UIColor whiteColor];

	[shopPrints setHighColor:highColor];
	[shopPrints setLowColor:lowColor];
	shopPrints.layer.borderColor = [borderColor CGColor];
	shopPrints.layer.borderWidth = 1;
	shopPrints.layer.cornerRadius = 18;
	shopPrints.titleLabel.textColor = textColor;
	shopPrints.titleLabel.layer.shadowColor = [textShadowColor CGColor];
	shopPrints.titleLabel.layer.shadowOffset = CGSizeMake( 1, 1 );

	[shopPhotoGift setHighColor:highColor];
	[shopPhotoGift setLowColor:lowColor];
	shopPhotoGift.layer.borderColor = [borderColor CGColor];
	shopPhotoGift.layer.borderWidth = 1;
	shopPhotoGift.layer.cornerRadius = 18;
	shopPhotoGift.titleLabel.textColor = textColor;
	shopPhotoGift.titleLabel.layer.shadowColor = [textShadowColor CGColor];
	shopPhotoGift.titleLabel.layer.shadowOffset = CGSizeMake( 1, 1 );

	// ----------------------------------------------------------------
	// Wire up the button actions
	// ----------------------------------------------------------------

	[shopPrints addTarget:@"tt://buyPrints/web/cart" action:@selector(openURLFromButton:) forControlEvents:UIControlEventTouchUpInside];

	[shopPhotoGift addTarget:self action:@selector(shopPhotoGiftsAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    // Update the text of the Prints button based on items in the cart
    if ( [CartModel cartModel].photos.count > 0 )
    {
        [shopPrints setTitle:@"Continue Order" forState:UIControlStateNormal];
    }
    else
    {
        [shopPrints setTitle:@"Start Order" forState:UIControlStateNormal];
    }
    
    [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Shop:Tab"];
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view.

	TT_RELEASE_SAFELY( shopPrints )
	TT_RELEASE_SAFELY( shopPhotoGift )
	TT_RELEASE_SAFELY( signInAlertView )
    
    TT_RELEASE_SAFELY( makePrintsLabel )
    TT_RELEASE_SAFELY( printsPriceLabel )
    
    TT_RELEASE_SAFELY( makeMagnetsLabel )
    TT_RELEASE_SAFELY( magnetPriceLabel )
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

#pragma mark Actions

- (void)shopPhotoGiftsAction:(id)sender
{
	if ( ![UserModel userModel].loggedIn )
	{
		TT_RELEASE_SAFELY( signInAlertView )
		signInAlertView = [[AnonymousSignInModalAlertView alloc] initWithAlbum:nil];
		[signInAlertView setFeatureRequiresLoginMessage];
		[signInAlertView show];
	}
	else
	{
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Shop:Make Magnet"];
        
		// The first step for shopping for a photo gift is moving through the select album flow
		TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://selectAlbumModal"] applyAnimated:YES];
		SelectAlbumViewController *viewController = (SelectAlbumViewController *) [[TTNavigator navigator] openURLAction:action];

		// The product list is only single photos at the moment.
		viewController.allowMultiplePhotoSelection = NO;

		// When the selection completes, notify ourselves so that we can move on to the next step in
		// the provess without having to hard-code any product-related logic into the photo selection.
		viewController.selectPhotosDelegate = self;
	}
}

#pragma mark Select Photos Delegate

// Because the select single photo view can be landscape, we need to make sure we can get
// back to portait when the select photos process cancels.
- (void)forcePortraitOrientation
{
    // KLUDGE to force the shouldAutorotateToInterfaceOrientation to query again to force
    // the shop flows to be portrait. If we push and pop immediately, we can force portait again.
    if ( UIDeviceOrientationIsLandscape( [UIDevice currentDevice].orientation ) )
    {
        UIViewController *garbageController = [[[UIViewController alloc] init] autorelease];
        [self.navigationController pushViewController:garbageController animated:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)selectPhotosDidSelectPhotos:(NSArray *)photos inAlbum:(AbstractAlbumModel *)album
{
    // Because we only allow single photo selection, we're guarantreed that photos is an
	// array consisting of one element, and the element is a PhotoModel* instance.
	PhotoModel *photo = [photos objectAtIndex:0];

	// Pop back to ourselves to remove the select album from the navigation stack
	[[TTNavigator navigator].visibleViewController.navigationController dismissModalViewControllerAnimated:YES];

	// KLUDGE: We can't use the completion block because iOS 4.2 doesn't support that, so instead
	// we wait for the animation to complete, then move to the product list with the selected photo
	double delayInSeconds = 0.5;
	dispatch_time_t popTime = dispatch_time( DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC );
	dispatch_after( popTime, dispatch_get_main_queue(), ^( void )
	{
		[self forcePortraitOrientation];
        
        // Move to the product list now that the photo has been selected.
		NSString *url = [NSString stringWithFormat:@"tt://productList/%@/%@", album.albumId, photo.photoId];
		TTURLAction *action = [[TTURLAction actionWithURLPath:url] applyAnimated:YES];
		[[TTNavigator navigator] openURLAction:action];
	} );
}

- (void)selectPhotosDidCancel
{
    [[TTNavigator navigator].visibleViewController dismissModalViewControllerAnimated:YES];
}


@end
