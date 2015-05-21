//
//  SettingsViewController.m
//  MobileApp
//
//  Created by PTraeg on 7/11/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserModel.h"
#import "SettingsModel.h"
#import "SettingsDataSource.h"
#import "AlbumListTableViewController.h"
#import "SettingsSignOutItem.h"
#import "SettingDelegate.h"
#import "PushNotificationModel.h"
#import "AlbumListModel.h"
#import "MobileAppAppDelegate.h"
#import "CartModel.h"

@implementation SettingsViewController
@synthesize mailComposer = _mailComposer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ( ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) )
	{
		self.tableViewStyle = UITableViewStyleGrouped;
		self.title = @"Settings";
		[self.tableView setBackgroundColor:[UIColor colorWithRed:0.949f green:0.949f blue:0.949f alpha:1.0f]];
		resizeUploadsSwitch = [[UISwitch alloc] init];
		[resizeUploadsSwitch addTarget:self action:@selector(toggleResizeUploads:) forControlEvents:UIControlEventValueChanged];
	}
	return self;
}

- (void)dealloc
{
	[_hud release];
	[resizeUploadsSwitch release];
	[_mailComposer release];
	[super dealloc];
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[super didSelectObject:object atIndexPath:indexPath];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)createModel
{
	slideshowLength = [[SettingsModel settings] slideshowTransitionLength];
	resizeUploads = [[SettingsModel settings] resizeImagesOnUpload];

	[self updateDataSource];
}

- (void)updateDataSource
{
	NSString *slideshowSpeed = [NSString stringWithFormat:@"%@ second", [NSNumber numberWithInt:slideshowLength]];
	if ( slideshowLength != 1 )
	{
		slideshowSpeed = [slideshowSpeed stringByAppendingString:@"s"];
	}

	[resizeUploadsSwitch setOn:resizeUploads];

	UISwitch *commentsSwitch = [[[UISwitch alloc] init] autorelease];
	TTTableControlItem *commentsSwitchItem = [TTTableControlItem itemWithCaption:@"Comments" control:commentsSwitch];
	[commentsSwitch setOn:[[SettingsModel settings] commentsNotification]];

	UISwitch *likeSwitch = [[[UISwitch alloc] init] autorelease];
	TTTableControlItem *likeSwitchItem = [TTTableControlItem itemWithCaption:@"Likes" control:likeSwitch];
	[likeSwitch setOn:[[SettingsModel settings] likeNotification]];


	UISwitch *joinSwitch = [[[UISwitch alloc] init] autorelease];
	TTTableControlItem *joinSwitchItem = [TTTableControlItem itemWithCaption:@"Friends Join Albums" control:joinSwitch];
	[joinSwitch setOn:[[SettingsModel settings] albumJoinNotification]];

	UISwitch *uploadSwitch = [[[UISwitch alloc] init] autorelease];
	TTTableControlItem *uploadSwitchItem = [TTTableControlItem itemWithCaption:@"Photo Uploads" control:uploadSwitch];
	[uploadSwitch setOn:[[SettingsModel settings] uploadNotification]];

	[commentsSwitch addTarget:self action:@selector(toggleComments:) forControlEvents:UIControlEventValueChanged];
	[likeSwitch addTarget:self action:@selector(toggleLike:) forControlEvents:UIControlEventValueChanged];
	[joinSwitch addTarget:self action:@selector(toggleJoin:) forControlEvents:UIControlEventValueChanged];
	[uploadSwitch addTarget:self action:@selector(toggleUpload:) forControlEvents:UIControlEventValueChanged];

	NSArray *signInArray;
	if ( ![[UserModel userModel] loggedIn] )
	{
		signInArray = [NSArray arrayWithObjects:[TTTableTextItem itemWithText:@"Sign In" URL:@"tt://login"], [TTTableTextItem itemWithText:@"Create a FREE Account" URL:@"tt://register"], nil];
	}
	else
	{
		signInArray = [NSArray arrayWithObjects:[SettingsSignOutItem itemWithText:@"" caption:@"" signin:@"Signed in as:" emailid:[[UserModel userModel] email] buttonTitle:@"Sign out" delegate:self selector:@selector(logout:)], nil];
	}
	self.dataSource = [SettingsDataSource dataSourceWithArrays:

			@"Account",
			[NSArray arrayWithArray:signInArray],

			@"General",
			[NSArray arrayWithObjects:[TTTableRightCaptionItem itemWithText:@"Slideshow Speed" caption:slideshowSpeed URL:@"tt://settings/slideshowSpeed"], [TTTableTextItem itemWithText:@"Reset tips" delegate:self selector:@selector(resetTips)], nil],

			@"",
			[NSArray arrayWithObjects:[TTTableControlItem itemWithCaption:@"Resize Uploads" control:resizeUploadsSwitch], nil],

			@"Notifications",
			[NSArray arrayWithObjects:uploadSwitchItem, joinSwitchItem, commentsSwitchItem, likeSwitchItem, nil],

			@"Support",
			[NSArray arrayWithObjects:[TTTableTextItem itemWithText:@"Help" delegate:self selector:@selector(launchHelpPage)], [TTTableTextItem itemWithText:@"Tutorials" delegate:self selector:@selector(launchTutorialsPage)], nil],

			@"Info",
			[NSArray arrayWithObjects:[TTTableRightCaptionItem itemWithText:@"Version:" caption:[MobileAppAppDelegate applicationVersion]], [TTTableTextItem itemWithText:@"License Agreement" URL:@"tt://settings/displayEULA/1"], [TTTableTextItem itemWithText:@"Terms of Service" delegate:self selector:@selector(displayTOS)], [TTTableTextItem itemWithText:@"Credits" URL:@"tt://settings/displayCredits/1"], nil],

			@"",
			[NSArray arrayWithObjects:[TTTableTextItem itemWithText:@"Rate This App" delegate:self selector:@selector(rateThisApp)], [TTTableTextItem itemWithText:@"Tell a Friend" delegate:self selector:@selector(tellFriend)], [TTTableTextItem itemWithText:@"Feedback" delegate:self selector:@selector(sendFeedback)], nil], nil];


}

- (void)resetTips
{
	SettingsModel *settings = [SettingsModel settings];

	[settings setTipDisplayedCommentsButton:NO];
	[settings setTipDisplayedNewAlbumButton:NO];
	[settings setTipDisplayedUploadButton:NO];
	settings.tipDisplayedPhotoHole = NO;
	[settings setTipDisplayedPrintsTab:NO];
	[settings setWelcomeFriendMessageDisplayed:NO];
	[settings setWelcomeGeneralMessageDisplayed:NO];
	[settings setWelcomeGroupMessageDisplayed:NO];
	[[[[UIAlertView alloc] initWithTitle:@"Tips Reset"
								 message:@"Application tips have been reset.  Usage tips will now reappear in the application." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];

}

- (void)displayTOS
{
	NSString *termsUrl = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, @"/gallery/mobile/app/termsOfService.jsp"];
	NSString *termsTitle = @"Terms of Service";
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:termsUrl, @"url", termsTitle, @"title", nil];

	TTURLAction *actionUrl = [[[TTURLAction actionWithURLPath:@"tt://settings/displayDocument"] applyAnimated:YES] applyQuery:dictionary];
	[[TTNavigator navigator] openURLAction:actionUrl];
}

- (void)viewWillAppear:(BOOL)animated
{
	// By clearing the model we force it to update
	self.model = nil;
	self.navigationBarStyle = UIBarStyleBlack;

	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[[PushNotificationModel sharedModel] updateNotifications:[[UserModel userModel] sybaseId]];
}

#pragma mark MBProgressHUD

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
	TT_RELEASE_SAFELY(_hud)
}

- (void)toggleResizeUploads:(id)sender
{
	UISwitch *toggle = (UISwitch *) sender;

	[[SettingsModel settings] setResizeImagesOnUpload:toggle.on];
}


- (void)launchHelpPage
{
	NSString *helpUrl = @"http://gallerystudio.custhelp.com/app/answers/detail/a_id/3482";
	NSString *helpTitle = @"Help";
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:helpUrl, @"url", helpTitle, @"title", nil];

	TTURLAction *actionUrl = [[[TTURLAction actionWithURLPath:@"tt://settings/displayDocument"] applyAnimated:YES] applyQuery:dictionary];
	[[TTNavigator navigator] openURLAction:actionUrl];
}

- (void)launchTutorialsPage
{
	NSString *tutorialUrl = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kTutorialsLink];
	NSString *title = @"Tutorials";
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:tutorialUrl, @"url", title, @"title", nil];

	TTURLAction *actionUrl = [[[TTURLAction actionWithURLPath:@"tt://settings/displayDocument"] applyAnimated:YES] applyQuery:dictionary];
	[[TTNavigator navigator] openURLAction:actionUrl];
}

- (void)logout:(id)sender
{
	self.hud.labelText = @"Signing Out...";
	[self.hud show:YES];
	[NSTimer scheduledTimerWithTimeInterval:0.1f
									 target:self
								   selector:@selector(signout:)
								   userInfo:nil repeats:NO];
}

- (void)signout:(NSTimer *)pTimer
{
	[pTimer invalidate];
	[[UserModel userModel] logout];
    [[CartModel cartModel] clearCart];
    [[CartModel cartModel] clearStoreInfo];
    [[CartModel cartModel] setClearWebCart:YES];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAnyChange"];


    // Logging out results in a newly created anon account whose albumList should be empty.
	// Make sure the static albumList in the AlbumListModel has been cleared to reflect this
	[[AlbumListModel albumList] setAlbums:[NSArray array]];
	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Logout"];
	self.model = nil;
	[self.dataSource invalidate:YES];
	[self reload];

	[self.hud hide:YES];
	if ( [AlbumListTableViewController currentAlbumListTableViewController] )
	{
		[[AlbumListTableViewController currentAlbumListTableViewController] setLastRefreshDate:nil];
	}

    ((UIViewController *)[self.navigationController.tabBarController.viewControllers objectAtIndex:1]).tabBarItem.enabled = [[UserModel userModel] loggedIn];


}

- (void)toggleJoin:(id)sender
{
	UISwitch *toggle = (UISwitch *) sender;

	[[SettingsModel settings] setAlbumJoinNotification:toggle.on];
}

- (void)toggleUpload:(id)sender
{
	UISwitch *toggle = (UISwitch *) sender;

	[[SettingsModel settings] setUploadNotification:toggle.on];
}

- (void)toggleLike:(id)sender
{
	UISwitch *toggle = (UISwitch *) sender;

	[[SettingsModel settings] setLikeNotification:toggle.on];
}

- (void)toggleComments:(id)sender
{
	UISwitch *toggle = (UISwitch *) sender;

	[[SettingsModel settings] setCommentsNotification:toggle.on];
}

- (void)rateThisApp
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kAppStoreLink]];
	[[UIApplication sharedApplication] openURL:url];
	[self updateDataSource];
	[self reload];
}

- (void)tellFriend
{
	self.mailComposer = [[[MailComposer alloc] initWithViewController:self messageText:[NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kAppStoreLink] subjectText:nil sendToText:nil] autorelease];
	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Share:Email" eventName:@"event73"];

}

- (void)sendFeedback
{
	self.mailComposer = [[[MailComposer alloc] initWithViewController:self messageText:nil subjectText:@"Kodak Gallery Mobile App Feedback" sendToText:@"iphonesupport@kodakgallery.com"] autorelease];
	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Share:Email" eventName:@"event73"];
}

- (id <TTTableViewDelegate>)createDelegate
{
	SettingDelegate *delegate = [[SettingDelegate alloc] initWithController:self];

	return [delegate autorelease];
}
@end
