
//
//  MobileAppAppDelegate.m
//  MobileApp
//
//  Created by Jon Campbell on 5/24/11.
//  Copyright 2011 Kodak Gallery. All rights reserved.
//

#import "MobileAppAppDelegate.h"
#import "NSString+NSArrayFormatExtension.h"
#import "UserModel.h"
#import "EventListModel.h"
#import "PushNotificationModel.h"
#import "PushSettingsViewController.h"
#import "URLCache.h"
#import "AddThis.h"
#import "NavigationConfigure.h"
#import "RestKitConfigure.h"
#import "CartModel.h"

#if RELEASE != 1

#import "TestFlight.h"

#endif

#import <BugSense-iOS/BugSenseCrashController.h>


@interface MobileAppAppDelegate ()

- (void)navigateToRemoteNotificationUsingDictionary:(NSDictionary *)userInfo;

- (void)saveRemoteNotificationStateUsingNotification:(NSDictionary *)notification;

- (void)saveRemoteNotificationStateUsingBadge:(NSNumber *)badge andText:(NSString *)notificationText;

- (void)clearRemoteNotificationState;

- (void)fetchLatestRemoteNotificationIfPushBadgeCountMismatch;

- (void)fetchLatestRemoteNotification;

- (void)checkForPendingShareToken;

@end

@implementation MobileAppAppDelegate


@synthesize window = _window;

@synthesize managedObjectContext = __managedObjectContext;

@synthesize managedObjectModel = __managedObjectModel;

@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize incomingURLHandler = _incomingURLHandler;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.

	// Set the "shared cache" to our own URLCache implementation so we have more control on the image sizes that are cached.
	[[TTURLRequestQueue mainQueue] setMaxContentLength:0];
	[TTURLCache setSharedCache:[URLCache sharedCache]];

	[RestKitConfigure initializeMappings];

	// This user model is taken care of in the UserModel object
	[[[UserModel alloc] initWithSavedSessionOrAnonymousSession] autorelease];
	// Watch for changes to the loggedIn value
	[[UserModel userModel] addObserver:self forKeyPath:@"loggedIn" options:0 context:NULL];

	[NavigationConfigure initializeNavigation:self.window];
	[self initOmniture];

	[self.window makeKeyAndVisible];

	[self initReachability];

#if !( TARGET_IPHONE_SIMULATOR )

    PushNotificationModel *pushNotificationModel = [PushNotificationModel sharedModel];

    // Get the saved device token, or request it from Apple if we need one
    [pushNotificationModel checkDeviceTokenAndRegister];
    
    // Check what Notifications the user has turned on.  We registered for all three, but they
    // may have manually disabled some or all of them.
    NSNumber *enabledTypes = [NSNumber numberWithInt:[[UIApplication sharedApplication] enabledRemoteNotificationTypes]];	    
    
    // Make sure the enabled types didn't change, if they did and we're logged in
    // and have a device token then we need to reregister
    [pushNotificationModel checkEnabledTypes];

    UserModel *user = [UserModel userModel];    
    if (![pushNotificationModel.enabledTypes isEqual:enabledTypes] && [user loggedIn] && pushNotificationModel.deviceToken != nil )
    {
        pushNotificationModel.enabledTypes = enabledTypes;
        [pushNotificationModel registerForNotifications:[user sybaseId]];
    }
#endif

	// Listen for @"ClearUnreadRemoteNotifications" so we can clear the notification bar when
	// the new/unread notifications list has been successfully loaded from the server
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(clearRemoteNotificationState)
												 name:@"ClearUnreadRemoteNotifications"
											   object:nil];

	// Check launchOptions for notification details
	NSDictionary *launchOptionsRemoteNotifications = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if ( launchOptionsRemoteNotifications != nil )
	{
		NSLog( @"Launching app with a remote notification" );
		[self navigateToRemoteNotificationUsingDictionary:launchOptionsRemoteNotifications];
	}
	else
	{
		// Check to see if there are new remote notifications so the notification bar can
		// sync to the application badge.
		[self fetchLatestRemoteNotificationIfPushBadgeCountMismatch];

		// Check to see if there are any pending share metadata cookies in the browser.  This check is performed only once - the first time
		// the app is run.
		[self checkForPendingShareToken];
	}

	// let us know if zombies is enabled
	if ( getenv( "NSZombieEnabled" ) || getenv( "NSAutoreleaseFreedObjectCheckEnabled" ) )
	{
		NSLog( @"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!" );
	}

#if RELEASE != 1

	// This is the KodakGallery team token
//	[TestFlight takeOff:@"9321d6705004a3f7bf002ad64ca5f55f_MTk2ODkyMDExLTA5LTEyIDE0OjMxOjM4LjYwNzIxOA"];

	// This is the KodakGallery SPM team token
	[TestFlight takeOff:@"7f298d4eb63652a8ee35511fa47703c9_NzY1MzYyMDEyLTAzLTMwIDExOjU4OjQ3LjcwMDk0MQ"];

//    [NSClassFromString(@"WebView") _enableRemoteInspector];
#endif
	[BugSenseCrashController sharedInstanceWithBugSenseAPIKey:@"cab40c9b"];

	return YES;
}

#pragma mark KVO Observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( object == [UserModel userModel] && [keyPath isEqualToString:@"loggedIn"] )
	{
		// If the user went from logged out to logged in, check for unread remote notifications
		if ( [UserModel userModel].loggedIn )
		{
			[self fetchLatestRemoteNotification];
		}
		else
		{
			// https://jc.ofoto.com/jira/browse/STABTWO-1633
			// On signout we need to clear the remote notification information (the application badge
			// count, and the last saved remote notification information that populates the
			// notifiation bar)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ClearUnreadRemoteNotifications"
																object:self
															  userInfo:nil];
		}
	}
}

#pragma mark Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSString *deviceTokenString = [[deviceToken description] stringByReplacingOccurrencesOfString:@" " withString:@""];
	deviceTokenString = [deviceTokenString substringWithRange:NSMakeRange( 1, [deviceTokenString length] - 2 )];

	[PushNotificationModel sharedModel].deviceToken = deviceTokenString;

	// We registered with Apple OK, now we need to register with the model
	UserModel *user = [UserModel userModel];
	if ( [user loggedIn] )
	{
		[[PushNotificationModel sharedModel] registerForNotifications:[user sybaseId]];
	}
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
	NSLog( @"Error in APNS registration. Error: %@", err );

	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Error:Notification:Failed to Register"];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSLog( @"application:didReceiveRemoteNotification: %@", [userInfo description] );

	//AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );

	// Save the notification state to the user defaults so that we have
	// the value at startup, and the values are avaialble in the...
	// TRICKY ... event that the handler relies on the saved notification state
	[self saveRemoteNotificationStateUsingNotification:userInfo];

	// Post the notification and pass the notification information along with it.
	// This will trigger the NotificationBar to update.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRemoteNotification"
														object:self
													  userInfo:userInfo];

	// Check for app being brought from background to foreground via the notification ("View Now" or
	// from swiping the notification in the iOS5 notification center.
	if ( application.applicationState != UIApplicationStateActive )
	{
		// In this case, we want to navigate to the notification payload.
		[self navigateToRemoteNotificationUsingDictionary:userInfo];
	}
	else
	{
		// App is in the foreground.  Nothing to do becuase the NoticicationBar update
		// has been taken care of.
	}
}

- (void)saveRemoteNotificationStateUsingNotification:(NSDictionary *)notification
{
	NSDictionary *aps = [notification objectForKey:@"aps"];

	NSNumber *badge = [aps objectForKey:@"badge"];
	int badgeNumber = [badge integerValue];
	[UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;

	NSDictionary *alert = [aps objectForKey:@"alert"];
	NSString *locKey = [alert objectForKey:@"loc-key"];
	NSArray *locArgs = [alert objectForKey:@"loc-args"];

	NSString *notificationText = [NSString stringWithFormat:NSLocalizedString( locKey, @"" ) array:locArgs];

	[self saveRemoteNotificationStateUsingBadge:badge andText:notificationText];
}

- (void)saveRemoteNotificationStateUsingBadge:(NSNumber *)badge andText:(NSString *)notificationText
{
	// Write the last notification to the shared defaults so that when the application
	// starts up again with unread notifications, the initial content of the notification bar
	// can be populated correctly.
	[[NSUserDefaults standardUserDefaults] setObject:badge forKey:@"notificationBarBadgeNumber"];
	[[NSUserDefaults standardUserDefaults] setObject:notificationText forKey:@"notificationBarNotificationText"];
	[[NSUserDefaults standardUserDefaults] synchronize];

}

// Called via the notification center, when the remote notifications have been loaded (and
// therefore new notifications cleared) from the server.
- (void)clearRemoteNotificationState
{
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;

	// Clear the saved notification badge and text so that the next time the
	// application starts it doesn't think we have unread remote notifications
	// anymore.
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"notificationBarBadgeNumber"];
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"notificationBarNotificationText"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 Examines a remote notification and navigates the user to the appropriate user interface screen.
 
 Call when:
 1. The application is not running and is launched because of a notification
 2. The application is running in the background and a user views a notification
 */
- (void)navigateToRemoteNotificationUsingDictionary:(NSDictionary *)userInfo
{
	// Post a message so that the notification bar and badge counts clear
	//
	// FIXME This doesn't actually clear the notification on the server, it only clears the
	// content within the NotificationBar and clears the application badge.
	//
	// We need to make a server call to "mark this single event as viewed" - assuming we could
	// piece together the event id based on the push notification dictionary contents.
	// Once the call completes, we would then reduce the badge count and update the notification
	// text to display the latest unread remote notification text.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ClearUnreadRemoteNotifications"
														object:self
													  userInfo:nil];

	// TODO Perhaps we want to just call [self fetchLatestRemoteNotification] to update the
	// notification bar content from the server, and then try to remove the event described in
	// userInfo from the returned list because the user has "seen" this particular event (would could pass
	// te event id to the method, then filter the event from the event list and decrement the unread
	// event count by 1).
	// However, the next time a notification is pushed, the count will be incorrect again (because the
	// server won't know that this particular event is no longer new).

	TT_RELEASE_SAFELY(_eventNavController);
	_eventNavController = [[EventNavigationController alloc] init];
	[_eventNavController navigateToNotification:userInfo];
}

/*
 Loads the most recent notification from the server and saves the info to the standard
 user defaults to sync the notification bar if there are new notifications that we don't
 know about (because the notifications were received when we were not running or we were
 in the background and couldn't process them.
 */
- (void)fetchLatestRemoteNotificationIfPushBadgeCountMismatch
{
	int applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;

	NSNumber *badge = [[NSUserDefaults standardUserDefaults] objectForKey:@"notificationBarBadgeNumber"];
	int notificationBarBadgeNumber = [badge integerValue];

	// Check to see if there is new notification information on the server.  We do this if we have a larger
	// badge count than notification bar cunt (when push received in the background), or when the badge count
	// is nil / unknown (such as when a new user logs in).
	if ( applicationIconBadgeNumber > notificationBarBadgeNumber )
	{
		NSLog( @"New notifications detected." );

		[self fetchLatestRemoteNotification];
	}
}

/*
 Always loads the most recent notification information from the server.  This is useful both when we don't
 know the notification status (such as when a new user logs in), or when we know there are new notifications
 because we received push notifications while not running or while running in the background.
 */
- (void)fetchLatestRemoteNotification
{
	NSLog( @"Loading most recent notification from server." );

	EventListModel *eventList = [[EventListModel alloc] init];

	// TRICKY: We declare this as __block because we need to release it within the blocks, but the block
	// is required in the initializer (so, there is no valid reference to delegate yet)
	__block RKObjectLoaderBlockDelegate *delegate;

	DidLoadObjectsBlock didLoadObjectBlock = ^( RKObjectLoader *objectLoader, NSArray *objects )
	{
		NSNumber *unreadEventCount = eventList.unreadEventsCount;

		// Get the text of the most recent notification to display in the notification bar
		NSString *notificationText = nil;
		if ( [unreadEventCount intValue] > 0 && [eventList.events count] )
		{
			// Get the most recent notification out of the event
			EventModel *event = (EventModel *) [[eventList events] objectAtIndex:0];

			// The friendly description might be "Commented on photo", so we want to replace that
			// to say "User commented on photo".  The "User" text is the subject name, and then we need
			// to update the description to force the first letter to be lowercase.
			notificationText = [event.sanitizedSubjectName stringByAppendingString:@" "];
			NSString *lowercaseFirstLetter = [[event.friendlyDescription substringToIndex:1] lowercaseString];
			NSString *friendlyDescription = [event.friendlyDescription stringByReplacingCharactersInRange:NSMakeRange( 0, 1 )
																							   withString:lowercaseFirstLetter];
			notificationText = [notificationText stringByAppendingString:friendlyDescription];
		}

		// Check for unread events
		if ( [unreadEventCount intValue] > 0 )
		{
			// Simulate receiving a remote notificaiton by posting the notification. Note that we pass nil
			// through as the userInfo because the remote notification is read from the defaults we wrote above.
			[self saveRemoteNotificationStateUsingBadge:eventList.unreadEventsCount andText:notificationText];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRemoteNotification"
																object:self
															  userInfo:nil];

			// Sync the application badge to the unread event count
			[UIApplication sharedApplication].applicationIconBadgeNumber = [unreadEventCount intValue];
		}
		else
		{
			// In this case, we thought we had an unread remote notification, but by the time the call
			// returns it turns out we don't actually have anything unread.  This probably doesn't happen
			// or doesn't happen too often.

			// Make sure the application badge and notification bar gets cleared out
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ClearRemoteNotification"
																object:self
															  userInfo:nil];
		}

		// Use this to push executing a block off until the end of the current queue, which
		// allows RestKit to finish up what it was doing (and keeps the delegate around
		// as long as it is needed).  If delegate is released too early it's EXEC_BAD_ACCESS.
		dispatch_async( dispatch_get_current_queue(), ^
		{
			[eventList release];
			[delegate release];
		} );
	};

	// Block to use for both of the failure cases
	void (^didFailLoadObjectBlock)( void ) = ^
	{
		// Could not load new notifications to sync.  Default to badge number and "New Notification" test.

		// Simulate receiving a remote notificaiton by posting the notification. Note that we pass nil
		// through as the userInfo because the remote notification is read from the defaults we wrote above.
		int applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
		NSString *notificationText = ( applicationIconBadgeNumber == 1 ) ? @"New Notification" : @"New Notifications";
		[self saveRemoteNotificationStateUsingBadge:[NSNumber numberWithInt:applicationIconBadgeNumber] andText:notificationText];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRemoteNotification"
															object:self
														  userInfo:nil];

		// Use this to push executing a block off until the end of the current queue, which
		// allows RestKit to finish up what it was doing (and keeps the delegate around
		// as long as it is needed).  If delegate is released too early it's EXEC_BAD_ACCESS.
		dispatch_async( dispatch_get_current_queue(), ^
		{
			[eventList release];
			[delegate release];
		} );
	};

	delegate = [[RKObjectLoaderBlockDelegate alloc] initWithOnFail:^( RKObjectLoader *objectLoader, NSError *error )
																   {
																	   didFailLoadObjectBlock();
																   }
												  andOnLoadObjects:didLoadObjectBlock
											   andOnLoadUnexpected:^( RKObjectLoader *objectLoader )
																   {
																	   didFailLoadObjectBlock();
																   }];


	// Don't clear the badge count here because the user has not loaded the notifications screen.  We only make
	// this call so we can load the most recent notification from the server to populate the NotificationBar
	// correctly.
	[eventList fetchUsingDelegate:delegate clearBadgeCount:NO];

	// Don't release here, we need to keep this around long enough for it to execute when the
	// result comes back, so we'll actually release it in the completion/error blocks, above.
	//[eventList release];
	//[delegate release];
}


/*
 Opens the Safari browser to check if there are any pending shares that might need to be claimed.
 This test is run only once - upon running the app for the first time.   This way the user does not have to click the share link
 in their share email a 2nd time if they are attempted to view a share and have just installed the app.
 */
- (void)checkForPendingShareToken
{
	if ( ![[SettingsModel settings] pendingShareTokenChecked] )
	{
		[[SettingsModel settings] setPendingShareTokenChecked:YES];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kPendingShareURL]];
		[[UIApplication sharedApplication] openURL:url];
	}
}

#pragma mark - Reachability

- (void)initReachability
{
	networkWasPreviouslyReachable = true;

	RKReachabilityObserver *restKitReachability = [[RKClient sharedClient] baseURLReachabilityObserver];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reachabilityChanged:)
												 name:RKReachabilityStateChangedNotification
											   object:nil];

	// Determine the initial reachability value
	[self updateReachability:restKitReachability];

}


- (void)reachabilityChanged:(NSNotification *)notification
{
	RKReachabilityObserver *observer = (RKReachabilityObserver *) [notification object];
	[self updateReachability:observer];
}

- (void)registerObjectMappings {

}

- (void)initNavigationController {

}


- (void)updateReachability:(RKReachabilityObserver *)observer
{
	BOOL networkIsCurrentlyReachable = [observer isNetworkReachable];
	if ( !networkIsCurrentlyReachable )
	{
		noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
													   message:@"You must connect to a Wi-Fi or your carrier's network to access KODAK Gallery."
													  delegate:self
											 cancelButtonTitle:@"Retry"
											 otherButtonTitles:nil];
		[noConnectionAlert show];

		// Move the user to the network unavailable view since we can't reach the internet
		//[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"tt://errors/networkUnavailable"]];

	}
	else // Internet is currently reachable
	{
		if ( !networkWasPreviouslyReachable )
		{
			[noConnectionAlert dismissWithClickedButtonIndex:0 animated:YES];
			[noConnectionAlert release];

			// Reload the data for the current screen that we're on
			UIViewController *visibleViewController = [[TTNavigator navigator] visibleViewController];
			if ( [visibleViewController isKindOfClass:[TTModelViewController class]] )
			{
				[(TTModelViewController *) visibleViewController reload];
			}
		}
	}

	networkWasPreviouslyReachable = networkIsCurrentlyReachable;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ( alertView == noConnectionAlert )
	{
		RKReachabilityObserver *restKitReachability = [[RKClient sharedClient] baseURLReachabilityObserver];
		[self performSelector:@selector(updateReachability:) withObject:restKitReachability afterDelay:2];
	}
}

- (BOOL)displayGroupOrFriendWelcomeScreenForURL:(NSURL *)url
{
	NSArray *parameters = [[url query] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
	if ( [parameters indexOfObject:@"groupId"] != NSNotFound )
	{
		if ( ![[SettingsModel settings] welcomeGroupMessageDisplayed] )
		{
			[[SettingsModel settings] setWelcomeGroupMessageDisplayed:YES];
			return YES;
		}
		else
		{
			return NO;
		}
	}
	if ( [parameters indexOfObject:@"albumId"] != NSNotFound )
	{
		if ( ![[SettingsModel settings] welcomeFriendMessageDisplayed] )
		{
			[[SettingsModel settings] setWelcomeFriendMessageDisplayed:YES];
			return YES;
		}
		else
		{
			return NO;
		}
	}
	return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if ( [self displayGroupOrFriendWelcomeScreenForURL:url] )
	{
		// Show the welcome page which will ultimately call IncomingURLHandler itself
		NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:url, @"incomingUrl", nil];
		TTURLAction *actionUrl = [[[TTURLAction actionWithURLPath:@"tt://welcome/display"] applyAnimated:NO] applyQuery:dictionary];
		[[TTNavigator navigator] openURLAction:actionUrl];
	}
	else
	{
		// No welcome page - just get right to it.
		self.incomingURLHandler = [[[IncomingURLHandler alloc] initWithURL:url] autorelease];
	}
	return YES;
}

- (void)didJoinSucceed:(AbstractAlbumModel *)model
{
	TTNavigator *navigator = [TTNavigator navigator];
	[navigator openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://groupAlbum/%@", [model groupId]]]];

}

- (void)didJoinFail:(AbstractAlbumModel *)model error:(NSError *)error
{
	TTNavigator *navigator = [TTNavigator navigator];
	[navigator openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://groupAlbum/%@", [model groupId]]]];

}

- (void)initOmniture
{
	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Application:Open"];
}

- (void)initAddThis
{
	[AddThisSDK setNavigationBarColor:[UIColor lightGrayColor]];
	[AddThisSDK setToolBarColor:[UIColor lightGrayColor]];
	[AddThisSDK setSearchBarColor:[UIColor lightGrayColor]];
	[AddThisSDK canUserEditServiceMenu:YES];
	[AddThisSDK canUserReOrderServiceMenu:YES];

	[AddThisSDK setFacebookAuthenticationMode:ATFacebookAuthenticationTypeFBConnect];
	[AddThisSDK setFacebookAPIKey:kFacebookAPIKey];

	[AddThisSDK setAddThisPubId:kAddThisProfileId];
	[AddThisSDK setAddThisApplicationId:kAddThisApplicationId];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
*/
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

    // save the cart
    [[CartModel cartModel] persistCart];

    /*
    Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
*/

	// When the application comes to the foreground, potentially update the notification bar
	// if we received remote notifications that we weren't able to act on.
	[self fetchLatestRemoteNotificationIfPushBadgeCountMismatch];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
*/
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (void)dealloc
{
	// Remove the loggedIn KVO listener we added during application startup.
	[[UserModel userModel] removeObserver:self forKeyPath:@"loggedIn"];

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:RKReachabilityStateChangedNotification
												  object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"ClearUnreadRemoteNotifications"
												  object:nil];

	[_window release];
	[__managedObjectContext release];
	[__managedObjectModel release];
	[__persistentStoreCoordinator release];

	self.incomingURLHandler = nil;
	[_eventNavController release];

	[super dealloc];
}

- (void)awakeFromNib
{
	/*
 Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
 self.<#View controller#>.managedObjectContext = self.managedObjectContext;
*/
}

- (void)saveContext
{
	NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
	if ( managedObjectContext != nil )
	{
		if ( [managedObjectContext hasChanges] && ![managedObjectContext save:&error] )
		{
			/*
Replace this implementation with code to handle the error appropriately.

abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
*/
			NSLog( @"Unresolved error %@, %@", error, [error userInfo] );
			abort();
		}
	}
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
	if ( __managedObjectContext != nil )
	{
		return __managedObjectContext;
	}

	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if ( coordinator != nil )
	{
		__managedObjectContext = [[NSManagedObjectContext alloc] init];
		[__managedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
	if ( __managedObjectModel != nil )
	{
		return __managedObjectModel;
	}
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MobileApp" withExtension:@"momd"];
	__managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if ( __persistentStoreCoordinator != nil )
	{
		return __persistentStoreCoordinator;
	}

	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MobileApp.sqlite"];

	NSError *error = nil;
	__persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	if ( ![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error] )
	{
		/*
Replace this implementation with code to handle the error appropriately.

abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.

Typical reasons for an error here include:
* The persistent store is not accessible;
* The schema for the persistent store is incompatible with current managed object model.
Check the error message to determine what the actual problem was.


If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

If you encounter schema incompatibility errors during development, you can reduce their frequency by:
* Simply deleting the existing store:
[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

* Performing automatic lightweight migration by passing the following dictionary as the options parameter:
[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

*/
		NSLog( @"Unresolved error %@, %@", error, [error userInfo] );
		abort();
	}

	return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSString *)applicationVersion
{
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *) kCFBundleVersionKey];
	NSString *versionShort = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *versionCombined = [NSString stringWithFormat:@"%@ (%@)", versionShort, version];

	return versionCombined;
}


@end
