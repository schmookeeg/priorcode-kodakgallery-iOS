//
//  EventAlbumTTViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "AbstractAlbumModel.h"
#import "AnonymousSignInModalAlertView.h"
#import "CMPopTipView.h"
#import "EventInterceptWindow.h"

@interface AlbumListTableViewController : TTTableViewController <TTModelDelegate, AlbumModelDelegate, UITabBarDelegate, UITableViewDelegate, TTSearchTextFieldDelegate, UISearchDisplayDelegate, EventInterceptWindowDelegate, CMPopTipViewDelegate>
{
	UISearchDisplayController *searchDisplayController;

	UITextField *textField;
	UIBarButtonItem *_addAlbumButton;
    UIBarButtonItem *_settingsButton;
	AbstractAlbumModel *_album;
	AnonymousSignInModalAlertView *_signInAlertView;

	NSDate *_lastRefreshDate;

	CMPopTipView *_tipView;
	CMPopTipView *_printTipView;

    UISegmentedControl *_headerAlbumOptions;
    BOOL _omitAlbumSegmentBar;

    CGFloat _initialHeight;
}

+ (AlbumListTableViewController *)currentAlbumListTableViewController;

- (void)didApplicationBecomeActiveNotification:(NSNotification *)notification;

- (CGRect)rectForHeaderView;

@property ( nonatomic, retain ) UIBarButtonItem *settingsButton;
@property ( nonatomic, retain ) NSDate *lastRefreshDate;
@property ( nonatomic, retain ) UIBarButtonItem *addAlbumButton;
@property ( nonatomic, retain ) UITextField *textField;
@property ( nonatomic, retain ) AbstractAlbumModel *album;
@property ( nonatomic, retain ) AnonymousSignInModalAlertView *signInAlertView;
@property ( nonatomic, retain ) UISegmentedControl *headerAlbumOptions;

/**********************************************************************************
 Changes: created property of UISearchDisplayController and MapSearchControllerDelegate delegate.
 Date: 07-Sep-11
 Author: Diaspark Inc.
 *************************************************************************************/
@property ( nonatomic, retain ) UISearchDisplayController *searchDisplayController;

@end
