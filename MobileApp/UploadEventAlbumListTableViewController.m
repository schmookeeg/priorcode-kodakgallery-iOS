//
//  EventAlbumTTViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadEventAlbumListTableViewController.h"
#import "UploadEventAlbumListDataSource.h"

@implementation UploadEventAlbumListTableViewController

@synthesize textField, eventAlbum = _eventAlbum;


- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
	if ( ( self = [super init] ) )
	{
		[self setDataSource:[[[UploadEventAlbumListDataSource alloc] init] autorelease]];

		self.title = @"Select upload destination:";
		self.variableHeightRows = YES;

		headerView = [[self headerView] retain];

		[[self tableView] setTableHeaderView:headerView];


	}
	return self;
}

- (UIView *)headerView
{
	if ( headerView )
	{
		return headerView;
	}

	float w = [[UIScreen mainScreen] bounds].size.width;

	self.textField = [[[UITextField alloc] initWithFrame:CGRectMake( 8.0, 8.0, w - 16.0, 30.0 )] autorelease];

	[textField setPlaceholder:@"Add New Happening"];
	[textField setDelegate:self];
	[textField setBorderStyle:UITextBorderStyleRoundedRect];
	[textField setReturnKeyType:UIReturnKeyDone];

	CGRect headerViewFrame = CGRectMake( 0, 0, w, 48 );
	headerView = [[UIView alloc] initWithFrame:headerViewFrame];

	[headerView addSubview:textField];

	return headerView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
	self.hud.labelText = @"Loading";
	[self.hud show:YES];

	self.eventAlbum = [[[AbstractAlbumModel alloc] init] autorelease]; // will be retained by setter
	[self.eventAlbum setDelegate:self];

	[self.eventAlbum setName:[self.textField text]];
	[self.eventAlbum create];

	// force a refresh if accessed
	[[AlbumListModel albumList] setPopulated:NO];

	[self.textField setText:@""];
	[self.textField resignFirstResponder];

	return YES;
}

- (void)didCreateSucceed:(AbstractAlbumModel *)model albumId:(NSNumber *)albumId
{
	[self.hud hide:YES];

	[model setDelegate:nil];

	[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://upload/%@", albumId]] applyAnimated:YES]];
}


- (void)didCreateFail:(AbstractAlbumModel *)model error:(NSError *)error
{
	[self.hud hide:YES];

	[[[[UIAlertView alloc] initWithTitle:@"Creation Failed"
								 message:@"Album creation failed. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationController.navigationBarHidden = NO;

	// force a refresh from the back button
	[[self dataSource] invalidate:YES];
	[self reload];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didApplicationBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Upload:Album List"];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didApplicationBecomeActiveNotification:(NSNotification *)notification
{

	[[self dataSource] invalidate:YES];
	[self reload];
}

- (MBProgressHUD *)hud
{
	if ( !_hud )
	{
		_hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		_hud.delegate = self;
		_hud.removeFromSuperViewOnHide = YES;
		[self.navigationController.view addSubview:_hud];
	}

	return _hud;
}

- (void)hudWasHidden
{
	// Free up memory when the hud goes away by release it safely (which prevents
	// a dual-release in dealloc as well)
	TT_RELEASE_SAFELY(_hud)
}

- (void)dealloc
{
	[headerView release];
	[textField release];
	[_eventAlbum release];
	[_hud release];

	[super dealloc];
}

@end