//
//  IncomingURLHandler.m
//  MobileApp
//
//  Created by Jon Campbell on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IncomingURLHandler.h"
#import "EventAlbumModel.h"
#import "MyAlbumModel.h"
#import "AlbumListModel.h"
#import "FriendsAlbumModel.h"
#import "UserModel.h"
#import "SettingsModel.h"
#import "ShareTokenList.h"
#import "AlbumListTableViewController.h"


@implementation IncomingURLHandler

@synthesize album = _album, signInAlertView = _signInAlertView;

- (id)initWithURL:(NSURL *)url
{
	self = [super init];
	if ( self )
	{
		[self handleURL:url];
	}

	return self;
}

- (void)handleURL:(NSURL *)url
{
	NSLog( @"In application:openURL:sourceApplication:annotation:" );
	BOOL loggedIn = [[UserModel userModel] loggedIn];
	NSArray *pathComponents = [url pathComponents];

    if ( [[url host] isEqualToString:@"notification"] )
	{
		if ( loggedIn )
		{
			[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://notifications"] applyAnimated:YES]];
		}
		else
		{
			[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://login/returnToNotifications"] applyAnimated:YES]];
		}
	}

	else if ( [[url host] isEqualToString:@"login"] )
	{
		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://login"] applyAnimated:YES]];
	}

	else if ( [[url host] isEqualToString:@"share"] )
	{
		// make sure there are enough parameters in the URL
        
        if ( pathComponents == nil || [pathComponents count] < 2 )
		{
			return;
		}

		if ( [[pathComponents objectAtIndex:1] isEqualToString:@"view"] )
		{
			NSArray *parameters = [[url query] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
			if ( [parameters count] < 2 )
			{
				// We don't have a complete set of parameters - just exit
				return;
			}

			NSMutableDictionary *keyValueParm = [NSMutableDictionary dictionary];

			for ( int i = 0; i < [parameters count]; i = i + 2 )
			{
				[keyValueParm setObject:[parameters objectAtIndex:i + 1] forKey:[parameters objectAtIndex:i]];
			}

			NSString *mmcCode = [keyValueParm objectForKey:@"cm_mmc"];
			NSString *sourceId = [keyValueParm objectForKey:@"sourceId"];

			if ( [keyValueParm objectForKey:@"groupId"] != nil )
			{
				NSNumber *groupId = [NSNumber numberWithDouble:[[keyValueParm objectForKey:@"groupId"] doubleValue]];
				NSNumber *albumId = [NSNumber numberWithDouble:[[keyValueParm objectForKey:@"albumId"] doubleValue]];
				NSString *shareToken = [keyValueParm objectForKey:@"shareToken"];

				self.album = [[[EventAlbumModel alloc] init] autorelease];
				self.album.groupId = groupId;
				self.album.albumId = albumId;
				self.album.shareToken = shareToken;

				// lets join, refresh the album list, then view it
				[self.album setDelegate:self];
				[self.album join];

				if ( mmcCode != nil && sourceId != nil )
				{
					[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Share Redeem:Group Album" mmcCode:mmcCode sourceId:sourceId];
				}
				else
				{
					[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Share Redeem:Group Album"];
				}

			}
			else if ( [keyValueParm objectForKey:@"albumId"] != nil )
			{
				NSNumber *albumId = [NSNumber numberWithDouble:[[keyValueParm objectForKey:@"albumId"] doubleValue]];
				NSString *shareToken = [keyValueParm objectForKey:@"shareToken"];
				BOOL allowAnon = [[keyValueParm objectForKey:@"allowAnon"] isEqualToString:@"true"];

				self.album = [[[FriendsAlbumModel alloc] init] autorelease];

				self.album.albumId = albumId;
				self.album.shareToken = shareToken;
				self.album.allowAnon = allowAnon;

				// For share purposes we set a single album in the list if anonymous

				if ( !loggedIn )
				{
					[[AlbumListModel albumList] setAlbums:[NSArray arrayWithObjects:self.album, nil]];
					if ( allowAnon )
					{
						// Store the token so it can be redeeemed if they choose to sign-in later
						[ShareTokenList addToken:self.album.shareToken forAlbumId:self.album.albumId];

						// For anon shares we redeem the share into the user's anon account so they can view it later
						[self.album setDelegate:self];
						[self.album join];

						// let the anonymous warning dialog handle the redirect for us
						[[SettingsModel settings] setAlbumListAnonymousWarningShown:YES];
						self.signInAlertView = [[[AnonymousSignInModalAlertView alloc] initWithAlbum:self.album] autorelease];
						[_signInAlertView show];
					}
					else
					{
						[[[[TTNavigator navigator] visibleViewController] navigationController] popToRootViewControllerAnimated:NO];
						[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://login/%@/YES", _album.albumId]] applyAnimated:YES]];
						/*
							  self.signInAlertView = [[[AnonymousSignInModalAlertView alloc] initWithAlbum:self.album] autorelease];
	  //                        _signInAlertView.alertTitle = @"";
							  _signInAlertView.alertMessage = @"Sign in, or create a free acount, to view this share.";
							  [_signInAlertView show];
							   */

					}

				}
				else
				{
					// otherwise, lets join, refresh the album list, then view it
					[self.album setDelegate:self];
					[self.album join];
				}
				if ( mmcCode != nil && sourceId != nil )
				{
					[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Share Redeem:Friends Album" mmcCode:mmcCode sourceId:sourceId];
				}
				else
				{
					[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Share Redeem:Friends Album"];
				}
			}
		}
	}
}

- (void)writeShareToken
{

}

- (void)setDirtyAlbumListView
{
	// Invalidate the lastUpdated flag in the AlbumListTableViewController to force it to refresh
	UIViewController *currentViewController = [[TTNavigator navigator] visibleViewController];

	NSArray *viewControllerStack = [[currentViewController navigationController] viewControllers];
	for ( id viewController in viewControllerStack )
	{
		if ( [viewController isKindOfClass:[AlbumListTableViewController class]] )
		{
			[(AlbumListTableViewController *) viewController setLastRefreshDate:nil];
		}
	}
}

#pragma mark - AlbumModelDelegate

- (void)didJoinSucceed:(AbstractAlbumModel *)model
{
	AlbumListModel *albumList = [AlbumListModel albumList];
	albumList.delegate = self;
	[albumList fetch];
}

- (void)didJoinFail:(AbstractAlbumModel *)model error:(NSError *)error
{
	NSLog( @"Join failure on app redeem" );

	[[[[UIAlertView alloc] initWithTitle:@"Server Error"
										 message:@"We are having difficulties performing your request. Please try again." delegate:nil
							   cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
}

#pragma mark - AbstractModelDelegate

- (void)didModelLoad:(AbstractModel *)model
{
	// We may get multiple didModelLoad events for the albumList - this is because the AlbumListScreen may have fetched the list as well and
	// that request may go out around the same time we send our join request.   We check to ensure that our album list is present in the 
	// model that was loaded before continuing to the thumbnail display.
	if ( [[AlbumListModel albumList] albumFromAlbumId:self.album.albumId] != nil )
	{
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://album/%@", self.album.albumId]]];
		[self setDirtyAlbumListView];
	}
}

- (void)dealloc
{
	self.album = nil;
	self.signInAlertView = nil;

	[super dealloc];
}


@end
