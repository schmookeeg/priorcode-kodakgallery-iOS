//
//  AddExistingAlbumViewController.m
//  MobileApp
//
//  Created by Dev on 6/10/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "AddExistingAlbumViewController.h"


@implementation AddExistingAlbumViewController
@synthesize eventAlbum = _eventAlbum;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		// Custom initialization
	}
	return self;
}

- (void)dealloc
{
	[albumIdInput release];
	[addAlbumButton release];
	[_hud release];
	[_eventAlbum release];

	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[self navigationItem] setTitle:@"Add Existing Album"];
	[[self navigationController] setNavigationBarHidden:NO];

	[addAlbumButton setEnabled:YES];

	[albumIdInput setText:@"983254762215"];

	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Add Existing Album"];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
	[albumIdInput release];
	albumIdInput = nil;
	[addAlbumButton release];
	addAlbumButton = nil;
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
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

- (IBAction)addAlbumButton:(id)sender
{
	self.hud.labelText = @"Joining album...";
	[self.hud show:YES];

	self.eventAlbum = [[[AbstractAlbumModel alloc] init] autorelease]; // will be retained by setter
	[self.eventAlbum setDelegate:self];

	NSNumber *groupId = [NSNumber numberWithLongLong:[[albumIdInput text] longLongValue]];

	[self.eventAlbum setGroupId:groupId];
	[self.eventAlbum join];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self addAlbumButton:nil];

	return YES;
}

#pragma mark - EventAlbumModelDelegate
- (void)didJoinSucceed:(AbstractAlbumModel *)model;
{
	[self.hud hide:YES];
	NSString *urlPath = [NSString stringWithFormat:@"tt://groupAlbum/%@", [albumIdInput text]];
	[[self navigationController] popViewControllerAnimated:NO];
	[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:urlPath] applyAnimated:YES]];
}

- (void)didJoinFail:(AbstractAlbumModel *)model error:(NSError *)error;
{
	[self.hud hide:YES];
	[[[[UIAlertView alloc] initWithTitle:@"Join Failed"
								 message:@"We are unable to add this album to your account. Please check the album id and try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
}

@end
