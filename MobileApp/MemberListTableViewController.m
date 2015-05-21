//
//  MemberListTableViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MemberListTableViewController.h"
#import "MemberListDataSource.h"

@implementation MemberListTableViewController

@synthesize shareActionController = _shareActionController;
@synthesize thumbViewController = _thumbViewController;

- (id)initWithEventAlbum:(AbstractAlbumModel *)eventAlbum
{
	self = [super init];
	if ( self )
	{
		self.dataSource = [[[MemberListDataSource alloc] initWithEventAlbum:eventAlbum] autorelease];
		self.variableHeightRows = YES;
		self.title = [NSString stringWithFormat:@"Friends of %@", eventAlbum.name];
	}

	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationController.navigationBarHidden = NO;

	// force a refresh from the back button
	[[self dataSource] invalidate:YES];
	[self reload];

	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:_shareActionController action:@selector(showOptions)] autorelease];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done)] autorelease];


	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Album List:Group Album:Member List"];
}

- (void)dealloc
{
	[_shareActionController release];
	[_thumbViewController release];

	[super dealloc];
}

- (void)done
{
	[UIView beginAnimations:@"animation" context:nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
	[UIView setAnimationDuration:.7];
	[UIView commitAnimations];
	[self.navigationController popViewControllerAnimated:NO];
}

#pragma mark ShareActionSheetControllerDelegate

- (UIView *)view
{
	return [super view];
}

- (UINavigationController *)navigationController
{
	return [super navigationController];
}

@end
