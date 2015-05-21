//
//  NotificationsViewController.m
//  MobileApp
//
//  Created by Darron Schall on 9/15/11.
//

#import "NotificationsViewController.h"
#import "EventListDataSource.h"
#import "UserModel.h"

@interface NotificationsViewController (Private)

- (void)populateNotificationBarFromRemoteNotificationState;
- (void)handleIncomingNotification:(NSNotification *)userInfo;
- (void)clearNotificationBarBadge;

@end

@implementation NotificationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		self.title = @"Activity";
		self.variableHeightRows = YES;

        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Activity" image:[UIImage imageNamed:@"ActivityTab.png"] tag:0] autorelease];
        self.tabBarItem.enabled = [[UserModel userModel] loggedIn];


        // Listen for @"DidReceiveRemoteNotification" so we can pass information to the notification bar
               [[NSNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(handleIncomingNotification:)
                                                            name:@"DidReceiveRemoteNotification"
                                                          object:nil];
               // Listen for @"ClearUnreadRemoteNotifications" so we can clear the notification bar when
               // the new/unread notifications list has been successfully loaded from the server
               [[NSNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(clearNotificationBarBadge)
                                                            name:@"ClearUnreadRemoteNotifications"
                                                          object:nil];

               [self populateNotificationBarFromRemoteNotificationState];

    }
	return self;
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

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;

	EventListDataSource *eventListDataSource = [[EventListDataSource alloc] init];
	self.dataSource = eventListDataSource;
	[eventListDataSource release];
}

- (void)populateNotificationBarFromRemoteNotificationState {
    // Pull the saved notification data out of the user defaults so we can restore the notification
    // bar state if the user has unread notifications that they haven't look at yet.
    NSNumber *badge = [[NSUserDefaults standardUserDefaults] objectForKey:@"notificationBarBadgeNumber"];
    self.tabBarItem.badgeValue = [badge stringValue];


    /*
    // If we have unread notifications to show in the notification bar, grab
    // the last saved notification to display that as well.
    if (badgeNumber) {
        NSString *notificationText = [[NSUserDefaults standardUserDefaults] objectForKey:@"notificationBarNotificationText"];
        notificationBar.notificationText = notificationText;
    } */
}

- (void)handleIncomingNotification:(NSNotification *)notification {
    // TRICKY Ignore the notification parameter and instead pull the notification
    // from the last remote notification that was saved to the user defaults.
    // SEE MobileAppAppDelegate saveRemoteNotificationStateUsingNotification
    [self populateNotificationBarFromRemoteNotificationState];
}

- (void)clearNotificationBarBadge {
    self.tabBarItem.badgeValue = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

#pragma mark -

- (void)doneButtonClicked:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldOpenURL:(NSString *)URL
{
	return NO;
}

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
	EventListDataSource *eventListDataSource = (EventListDataSource *) self.dataSource;
	EventModel *event = (EventModel *) [eventListDataSource.eventList.events objectAtIndex:indexPath.row];

	TT_RELEASE_SAFELY(_eventNavController);
	_eventNavController = [[EventNavigationController alloc] init];
	[_eventNavController navigateToEvent:event];
}

// Add DragRefresh delegate to provide pull-to-refresh support
- (id <TTTableViewDelegate>)createDelegate
{
	TTTableViewDragRefreshDelegate *delegate = [[TTTableViewDragRefreshDelegate alloc] initWithController:self];

	return [delegate autorelease];
}

- (void)dealloc
{
	self.dataSource = nil;
    TT_RELEASE_SAFELY(_eventNavController);
	
    [super dealloc];
}


@end
