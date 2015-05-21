//
//  PushSettingsViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PushSettingsViewController.h"
#import "PushNotificationModel.h"
#import "UserModel.h"

@implementation PushSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ( ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) )
	{
		self.title = @"Notification Settings";

		self.tableViewStyle = UITableViewStyleGrouped;

		settings = [SettingsModel settings];

		[self updateDataSource];
	}
	return self;
}

- (void)updateDataSource
{
	UISwitch *commentsSwitch = [[[UISwitch alloc] init] autorelease];
	TTTableControlItem *commentsSwitchItem = [TTTableControlItem itemWithCaption:@"Comments" control:commentsSwitch];
	[commentsSwitch setOn:[settings commentsNotification]];

	UISwitch *likeSwitch = [[[UISwitch alloc] init] autorelease];
	TTTableControlItem *likeSwitchItem = [TTTableControlItem itemWithCaption:@"Likes" control:likeSwitch];
	[likeSwitch setOn:[settings likeNotification]];


	UISwitch *joinSwitch = [[[UISwitch alloc] init] autorelease];
	TTTableControlItem *joinSwitchItem = [TTTableControlItem itemWithCaption:@"Album Joins" control:joinSwitch];
	[joinSwitch setOn:[settings albumJoinNotification]];

	UISwitch *uploadSwitch = [[[UISwitch alloc] init] autorelease];
	TTTableControlItem *uploadSwitchItem = [TTTableControlItem itemWithCaption:@"Uploads" control:uploadSwitch];
	[uploadSwitch setOn:[settings uploadNotification]];

	[commentsSwitch addTarget:self action:@selector(toggleComments:) forControlEvents:UIControlEventValueChanged];
	[likeSwitch addTarget:self action:@selector(toggleLike:) forControlEvents:UIControlEventValueChanged];
	[joinSwitch addTarget:self action:@selector(toggleJoin:) forControlEvents:UIControlEventValueChanged];
	[uploadSwitch addTarget:self action:@selector(toggleUpload:) forControlEvents:UIControlEventValueChanged];

	self.dataSource = [TTListDataSource dataSourceWithObjects:
			uploadSwitchItem,
			joinSwitchItem,
			likeSwitchItem,
			commentsSwitchItem,
			nil];
}

- (void)toggleJoin:(id)sender
{
	UISwitch *toggle = (UISwitch *) sender;

	[settings setAlbumJoinNotification:toggle.on];
}

- (void)toggleUpload:(id)sender
{
	UISwitch *toggle = (UISwitch *) sender;

	[settings setUploadNotification:toggle.on];
}

- (void)toggleLike:(id)sender
{
	UISwitch *toggle = (UISwitch *) sender;

	[settings setLikeNotification:toggle.on];
}

- (void)toggleComments:(id)sender
{
	UISwitch *toggle = (UISwitch *) sender;

	[settings setCommentsNotification:toggle.on];
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	[[PushNotificationModel sharedModel] updateNotifications:[[UserModel userModel] sybaseId]];
}


- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

@end
