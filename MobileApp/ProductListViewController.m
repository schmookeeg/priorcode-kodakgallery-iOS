//
//  ProductListViewController.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "ProductListViewController.h"
#import "SPMProductListDataSource.h"
#import "SelectAlbumViewController.h"

@interface ProductListViewController ()

- (void)applyBackgroundGradient;

@end

@implementation ProductListViewController

#pragma mark init / dealloc

- (id)initWithAlbumId:(NSString *)albumId photoId:(NSString *)photoId
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self )
    {
        self.title = @"Magnets";

		// Required for tableView:rowHeightForObject: support to size the table rows.
		self.variableHeightRows = YES;

		// Convert strings to numbers to pass to data source
		NSNumber *albumIdNumber = [NSNumber numberWithLongLong:[albumId longLongValue]];
		NSNumber *photoIdNumber = [NSNumber numberWithLongLong:[photoId longLongValue]];

        SPMProductListDataSource *dataSource = [[SPMProductListDataSource alloc] initWithAlbumId:albumIdNumber photoId:photoIdNumber];
        self.dataSource = dataSource;
        [dataSource release];

		// Remove the tab bar now that we're "inside" of the product flow.
		self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [_gradientLayer release];
    [super dealloc];
}

- (BOOL)showLogo
{
    return NO;
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // Create the banner at the top of the view
    UIImageView *shopTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shopTop.png"]];
	[self.view addSubview:shopTop];
	[shopTop release];

	// Adjust the table view down and shrink it a bit to make room for the banner
	CGRect tableViewFrame = self.tableView.frame;
	tableViewFrame.origin.y += shopTop.frame.size.height;
	tableViewFrame.size.height -= shopTop.frame.size.height;
	self.tableView.frame = tableViewFrame;

	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

	[self reload];

    [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Product List:Magnets"];

    UIViewController *c = [[UIViewController alloc]init];
    [self presentModalViewController:c animated:NO];
    [self dismissModalViewControllerAnimated:NO];
    [c release];

    [self applyBackgroundGradient];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)applyBackgroundGradient
{
	// Initialize the gradient layer
    if (_gradientLayer) {
        [_gradientLayer removeFromSuperlayer];
        [_gradientLayer release];
        _gradientLayer = nil;
    }

    CAGradientLayer *gradientLayer = _gradientLayer = [[CAGradientLayer alloc] init];

	// Create a bounding area for the empty space at the bottom
	CGRect bounds = self.view.bounds;
	gradientLayer.bounds = self.view.bounds;
	gradientLayer.position = CGPointMake( CGRectGetMidX( bounds ), CGRectGetMidY( bounds ) );

	UIColor *highColor = [UIColor colorWithRed:0x99 / 255.0 green:0x99 / 255.0 blue:0x99 / 255.0 alpha:1];
	UIColor *lowColor = [UIColor colorWithRed:0xE5 / 255.0 green:0xE5 / 255.0 blue:0xE5 / 255.0 alpha:1];
	NSArray *backgroundGradientColors = [NSArray arrayWithObjects:(id) [highColor CGColor], (id) [lowColor CGColor], nil];
	gradientLayer.colors = backgroundGradientColors;

	[self.view.layer insertSublayer:gradientLayer atIndex:0];
}

@end
