//
//  EventAlbumTTViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumListTableViewController.h"
#import "AlbumListTableViewController+AlbumSegmentBar.h"
#import "AlbumListDataSource.h"

#import "UserModel.h"
#import "SettingsModel.h"
#import "EmptyAlbumsView.h"
#import "MobileAppAppDelegate.h"

@interface AlbumListTableViewController (Private)

- (void)updateTableHeight;

- (CGRect)rectForEmptyView;

- (void)showTipsAlways:(BOOL)alwaysShow;
@end

static AlbumListTableViewController *_currentAlbumListTableViewController;

@implementation AlbumListTableViewController

@synthesize textField, album = _album;
@synthesize addAlbumButton = _addAlbumButton, signInAlertView = _signInAlertView, lastRefreshDate = _lastRefreshDate;
@synthesize searchDisplayController;
@synthesize headerAlbumOptions = _headerAlbumOptions;
@synthesize settingsButton = _settingsButton;

+ (AlbumListTableViewController *)currentAlbumListTableViewController {
    return _currentAlbumListTableViewController;
}

#pragma mark Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        if (!self.dataSource) {
            self.dataSource = [[[AlbumListDataSource alloc] init] autorelease];
        }
        NSLog(@"%@", self.dataSource);

        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Albums" image:[UIImage imageNamed:@"PhotosTab.png"] tag:0] autorelease];
        _omitAlbumSegmentBar = NO;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    TTTableViewController *searchController = [[[TTTableViewController alloc] init] autorelease];
    searchController.dataSource = [[[AlbumListDataSource alloc] init] autorelease];
    self.searchViewController = searchController;
}

- (id)initWithAlbumType:(NSString *)albumTypeString {
    if ((self = [super init])) {

        NSNumber *albumType = [NSNumber numberWithInteger:[albumTypeString integerValue]];

        // Setting the datasource for this TableViewController will automatically add the
        // TableViewController into the list of delegates maintained by the datasource.
        AlbumListDataSource *dataSource = [[[AlbumListDataSource alloc] initWithFilterAlbumType:albumType] autorelease];

        //    [dataSource setFilterAlbumType:[NSNumber numberWithInt:kFriendAlbumType]];

        [self setDataSource:dataSource];

        self.variableHeightRows = YES;

		self.addAlbumButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kAssetAddIcon]
																style:UIBarButtonItemStylePlain 
															   target:self 
															   action:@selector(addAlbum:)] autorelease];

        UIImage *settingsIcon = [UIImage imageNamed:kAssetSettingsIcon];
        self.settingsButton = [[[UIBarButtonItem alloc] initWithImage:settingsIcon 
																style:UIBarButtonItemStylePlain 
															   target:self 
															   action:@selector(displaySettings:)] autorelease];


    }

    _currentAlbumListTableViewController = self;

    return self;
}

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    return [self initWithAlbumType:[NSString stringWithFormat:@"%d", kAllAlbumType]];
}

- (void)dealloc {
    [textField release];
    [_album release];
    [_addAlbumButton release];

    self.lastRefreshDate = nil;
    self.signInAlertView = nil;
    self.dataSource = nil;
    self.headerAlbumOptions = nil;

    TT_RELEASE_SAFELY(_tipView)
    TT_RELEASE_SAFELY(_printTipView)

    [[TTNavigator navigator].URLMap removeURL:@"tt://displayAlbumTypeChoices"];

    _currentAlbumListTableViewController = nil;

    [searchDisplayController release];

    [_settingsButton release];
    [super dealloc];
}

#pragma mark View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = NO;

    self.navigationItem.title = @"Albums";
    self.navigationItem.leftBarButtonItem = self.settingsButton;
    self.navigationItem.rightBarButtonItem = self.addAlbumButton;
    BOOL isAnyChange = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAnyChange"];
    // Refresh if more than kAlbumListRefreshSeconds seconds have past since we last refreshed the album list (timeIntervalSinceNow will return negative values)
    if (_lastRefreshDate == nil || [_lastRefreshDate timeIntervalSinceNow] < kAlbumListRefreshSeconds * -1 || isAnyChange) {
        [[self dataSource] invalidate:YES];
        [self reload];
        self.lastRefreshDate = [[[NSDate alloc] init] autorelease];
    }

    if (isAnyChange) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isAnyChange"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    AlbumListDataSource *dataSource = (AlbumListDataSource *) self.dataSource;
    [self selectTabFromAlbumType:dataSource.filterAlbumType];

    if (_flags.isShowingEmpty) {
        self.emptyView.frame = [self rectForEmptyView];
    }

    UIViewController *const controller = ((UIViewController *) [self.navigationController.tabBarController.viewControllers objectAtIndex:1]);
    controller.tabBarItem.enabled = [[UserModel userModel] loggedIn];

    //end

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didApplicationBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [self updateTableHeight];
}

- (void)refreshAlbumList:(NSNotification *)notification {
    [[self dataSource] invalidate:YES];
    [self reload];
    self.lastRefreshDate = [NSDate date];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    BOOL isLoggedIn = [[UserModel userModel] loggedIn];

    if (!isLoggedIn && ![[SettingsModel settings] albumListAnonymousWarningShown]) {
        self.signInAlertView = [[[AnonymousSignInModalAlertView alloc] init] autorelease];
        [self.signInAlertView show];
        [[SettingsModel settings] setAlbumListAnonymousWarningShown:YES];
    }

    // Register to receive touch events
    MobileAppAppDelegate *appDelegate = (MobileAppAppDelegate *) [[UIApplication sharedApplication] delegate];
    EventInterceptWindow *window = (EventInterceptWindow *) appDelegate.window;
    window.eventInterceptDelegate = self;

    self.tableView.tableHeaderView = nil;

    [self showTipsAlways:NO];
}

- (void)updateTableHeight {

    // Resize the tableview to ensure the last row is not partially obscured by the tabBarView
    CGRect tableFrame = [_tableView frame];
    if (!_omitAlbumSegmentBar) {
        CGSize headerSize = [self rectForHeaderView].size;
        self.tableView.frame = CGRectMake(0, headerSize.height + 15, tableFrame.size.width, _initialHeight - headerSize.height - self.tableBannerView.frame.size.height - 15);
    } else {
        self.tableView.frame = CGRectMake(0, 0, tableFrame.size.width, _initialHeight - self.tableBannerView.frame.size.height);

    }
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAlbumList:) name:@"RefreshAlbumList" object:nil];

    if (!_omitAlbumSegmentBar && [self respondsToSelector:@selector(setupAlbumNavigation)]) {
        [self performSelector:@selector(setupAlbumNavigation)];
    }

    _initialHeight = _tableView.frame.size.height - ((self.hidesBottomBarWhenPushed) ? 0 : 49);

    self.navigationBarStyle = UIBarStyleBlack;
    self.navigationBarTintColor = nil;
}


- (void)viewDidUnload {
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshAlbumList" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Deregister from receiving touch events
    MobileAppAppDelegate *appDelegate = (MobileAppAppDelegate *) [[UIApplication sharedApplication] delegate];
    EventInterceptWindow *window = (EventInterceptWindow *) appDelegate.window;
    window.eventInterceptDelegate = nil;

    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
#pragma mark -

- (void)showTipsAlways:(BOOL)alwaysShow {
    AlbumListDataSource *dataSource = (AlbumListDataSource *) self.dataSource;
    if (![dataSource.filterAlbumType isEqualToNumber:[NSNumber numberWithInt:kFriendAlbumType]]) {
        // Focused on an album type other than Friends albums so we have a "create album" button available
        if (alwaysShow || ![[SettingsModel settings] tipDisplayedNewAlbumButton]) {
            // Haven't displayed the New albums tip
            if (_tipView != nil && _tipView.targetObject != nil) {
                [_tipView dismissAnimated:YES];
                [_tipView release];
            }
            _tipView = [[CMPopTipView alloc] initWithMessage:@"Tap here to create\na new album"];
            _tipView.backgroundColor = POPTIP_BACKGROUND_COLOR;
            _tipView.textColor = POPTIP_TEXT_COLOR;
            _tipView.delegate = nil;
            _tipView.animation = CMPopTipAnimationPop;
            [_tipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
        }
    }
    if (![[SettingsModel settings] tipDisplayedPrintsTab]) {
        // Haven't displayed the prints tip
        if (_printTipView != nil && _printTipView.targetObject != nil) {
            [_printTipView dismissAnimated:YES];
            [_printTipView release];
        }
        _printTipView = [[[CMPopTipView alloc] initWithMessage:@"NEW! Buy Prints & Photo Gifts\nwith your photos"] retain];
        _printTipView.backgroundColor = POPTIP_BACKGROUND_COLOR;
        _printTipView.textColor = POPTIP_TEXT_COLOR;
        _printTipView.delegate = nil;
        _printTipView.animation = CMPopTipAnimationPop;

        // The item we wish to point at is actually in the tab bar and we can't get a reference to that view itself
        // So instead we'll fake it and point to a dummy 1px view that's positioned right above the print order tab
        CGRect dummyPrintTabViewFrame = CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height, 1, 1);
        UIView *dummyPrintTabView = [[[UIView alloc] initWithFrame:dummyPrintTabViewFrame] autorelease];
        [self.view addSubview:dummyPrintTabView];
        [_printTipView presentPointingAtView:dummyPrintTabView inView:self.view animated:YES];
    }

}

/**
 Override showEmpty behavior to place a custom view in the table based
 on which tab is selected.
 */
- (void)showEmpty:(BOOL)show {
    if (show) {
        NSString *nibName = nil;

        AlbumListDataSource *dataSource = (AlbumListDataSource *) self.dataSource;
        int currentAlbumType = [dataSource.filterAlbumType intValue];

        if (currentAlbumType == kAllAlbumType) {
            nibName = @"EmptyAllAlbumsView";
        }
        else if (currentAlbumType == kMyAlbumType) {
            nibName = @"EmptyMyAlbumsView";
        }
        else if (currentAlbumType == kFriendAlbumType) {
            nibName = @"EmptyFriendsAlbumsView";
        }
        else if (currentAlbumType == kEventAlbumType) {
            nibName = @"EmptyGroupAlbumsView";
        }


        if (nibName != nil) {
            NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:nibName
                                                              owner:self
                                                            options:nil];
            EmptyAlbumsView *emptyAlbumsView = (EmptyAlbumsView *) [nibViews objectAtIndex:0];

            self.emptyView = emptyAlbumsView;
            self.emptyView.frame = [self rectForEmptyView];
        }
        else {
            NSLog(@"Couldn't load empty albums view");
            self.emptyView = nil;
        }
        [self showTipsAlways:YES];
    }
    else {
        self.emptyView = nil;
    }
}

- (CGRect)rectForEmptyView {
    CGRect tableFrame = [_tableView frame];
    return CGRectMake(tableFrame.origin.x, tableFrame.origin.y - 40,
            tableFrame.size.width, tableFrame.size.height);
}


- (CGRect)rectForOverlayView {
    CGRect tableFrame = [_tableView frame];
    return CGRectMake(tableFrame.origin.x, tableFrame.origin.y,
            tableFrame.size.width, tableFrame.size.height - 49);
}


- (void)didApplicationBecomeActiveNotification:(NSNotification *)notification {
    if ([[[TTNavigator navigator] visibleViewController] isEqual:self]) {
        [[self dataSource] invalidate:YES];
        [self reload];
    }
}

- (void)modelDidFinishLoad:(id <TTModel>)model {
    [super modelDidFinishLoad:model];
    NSLog(@"model loaded");

//    [self refresh];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        // During editing...
        // The last row during editing will show an insert style button
        return UITableViewCellEditingStyleInsert;
    }

    return UITableViewCellEditingStyleNone;
}

#pragma mark Add Album

- (id)displayAlbumTypeChoices {
    TTActionSheetController *controller = [[TTActionSheetController alloc]
            initWithTitle:@"What type of album are you creating?"
                 delegate:self];

    [controller addButtonWithTitle:@"My Album" URL:[NSString stringWithFormat:@"tt://addNewAlbum/%d", kMyAlbumType]];
    [controller addButtonWithTitle:@"Group Album" URL:[NSString stringWithFormat:@"tt://addNewAlbum/%d", kEventAlbumType]];
    [controller addCancelButtonWithTitle:@"Cancel" URL:nil];

    [controller showFromBarButtonItem:self.addAlbumButton animated:YES];
    return [controller autorelease];
}

- (void)addAlbum:(id)sender {
    // Figure out what album type the user is currently looking at.  This album type is the value that
    // we will pre-select on the create album screen.  If we don't know the value, we'll show the action
    // sheet interstitial.

    AlbumListDataSource *dataSource = (AlbumListDataSource *) self.dataSource;
    NSNumber *albumType = dataSource.filterAlbumType;
    int albumTypeInt = [albumType intValue];

    // All albums or friend's albums we should show the interstitial
    if (albumTypeInt == kAllAlbumType || albumTypeInt == kFriendAlbumType) {
        [self displayAlbumTypeChoices];
    }
    else // My album or event album we can pass the album type directory to the create album screen
    {
        NSString *actionUrl = [NSString stringWithFormat:@"tt://addNewAlbum/%d", albumTypeInt];

        TTURLAction *action = [TTURLAction actionWithURLPath:actionUrl];
        action.animated = YES;

        [[TTNavigator navigator] openURLAction:action];
    }
}

- (BOOL)actionSheetController:(TTActionSheetController *)controller didDismissWithButtonIndex:(NSInteger)buttonIndex URL:(NSString *)URL {
    //TTDPRINT( @"buttonIndex: %d URL: %@", buttonIndex, URL);
    return (nil != URL);
}

- (BOOL)showLogo {
    return YES;
}

// Add DragRefresh delegate to provide pull-to-refresh support
- (id <TTTableViewDelegate>)createDelegate {

    TTTableViewDragRefreshDelegate *delegate = [[TTTableViewDragRefreshDelegate alloc] initWithController:self];

    return [delegate autorelease];
}

- (void)didBeginDragging {
    self.tableView.tableHeaderView = _searchController.searchBar;
}


- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    TT_RELEASE_SAFELY(_tipView);
}

- (BOOL)interceptEvent:(UIEvent *)event {
    // This ensures we are dismissing the pop-up tips only when the user's finger touches the glass
    // if they tap on an item in the filter bar the tips might need to re-appear and if we clear them
    // on UITouchPhaseEnd we will delete the tips we just drew
    NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches) {
        if (touch.phase == UITouchPhaseBegan) {
            if (_tipView != nil && _tipView.targetObject != nil) {
                [_tipView dismissAnimated:YES];
                [[SettingsModel settings] setTipDisplayedNewAlbumButton:YES];
            }
            if (_printTipView != nil && _printTipView.targetObject != nil) {
                [_printTipView dismissAnimated:YES];
                [[SettingsModel settings] setTipDisplayedPrintsTab:YES];
            }
            return NO;
        }
    }
    return NO;
}

- (void)displaySettings:(id)sender {
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"tt://settings"]];
}

@end
