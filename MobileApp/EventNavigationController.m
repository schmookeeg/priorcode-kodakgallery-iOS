//
//  EventNavigationController.m
//  MobileApp
//
//  Created by Darron Schall on 9/19/11.
//

#import "EventNavigationController.h"
#import <Three20/Three20.h>
#import "NotificationsViewController.h"

@implementation EventNavigationController

- (void)navigateToEvent:(EventModel *)event
{
	/*
For reference, Here are some of the navigation URLs that we'll need to construct

[map from:@"tt://album/(initWithAlbumId:)" toViewController:[ThumbViewController class]];
[map from:@"tt://album/photo/(initPhotoWithAlbumId:)" toViewController:[SinglePhotoViewController class]];
[map from:@"tt://album/photo/(initPhotoWithAlbumId:)/(photoId:)" toViewController:[SinglePhotoViewController class]];
[map from:@"tt://photoComments/(initWithPhotoId)" toViewController:[PhotoCommentsListTableViewController class]];
[map from:@"tt://photoComments/post/(initWithPhotoIdPost)" toViewController:[PhotoCommentsListTableViewController class]];
*/

	NSString *url = nil;

	if ( event.albumIdHint == nil )
	{
		// In some cases (eg: photos shared via the tray) the albumIdHint is not known.  We must first follow the 
		// event link to obtain the albumId and then continue with building the screen URL.
		_navigationEvent = event;
		_eventDetailAlbumModel = [[EventDetailAlbumModel alloc] init];
		[_eventDetailAlbumModel setDelegate:self];
		[_eventDetailAlbumModel fetchViaURL:event.eventLink];
		return;
	}


	if ( [event.predicateType isEqualToString:@"COMMENT"] )
	{
		if ( [event.objectType isEqualToString:@"PHOTO"] )
		{
			//url = [NSString stringWithFormat:@"tt://photoComments/%d", self.albumIdHint];
			url = [NSString stringWithFormat:@"tt://album/photo/%@/%@", event.albumIdHint, event.objectId];
		}
	}
	else if ( [event.predicateType isEqualToString:@"LIKE"] )
	{
		if ( [event.objectType isEqualToString:@"PHOTO"] )
		{
			url = [NSString stringWithFormat:@"tt://album/photo/%@/%@", event.albumIdHint, event.objectId];
		}
	}
	else if ( [event.predicateType isEqualToString:@"UPLDCOMPLETE"]
			|| [event.predicateType isEqualToString:@"REDEEM"]
			|| [event.predicateType isEqualToString:@"SHARE"] )
	{
		url = [NSString stringWithFormat:@"tt://album/%@", event.objectId];
	}

	// Check to see if a URL could not be constructed, and try to make a default one
	if ( !url )
	{
		NSLog( @"navigateToEvent: Could not construct URL for predicate: %@ object: %@", event.predicateType, event.objectType );

		// Are we NOT on the notification view?
		if ( ![[TTNavigator navigator].topViewController isKindOfClass:[NotificationsViewController class]] )
		{
			// Default case is navigate to the notification screen
			url = @"tt://notifications";
		}
		// else, already on the notification screen so we don't need to go there again
	}

	// Only navigate if we have a valid URL to go to
	if ( url )
	{
		//TTAlert( [NSString stringWithFormat:@"navigateToEvent url: %@", url] );
		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:url] applyAnimated:NO]];
	}
}

- (void)navigateToNotification:(NSDictionary *)notification
{
	/* Example notification data looks like:
 albumId = 42565560603;
 aps = {
	alert = {
		"action-loc-key" = "View Now";
		"loc-args" = (
			Darron1
		);
		"loc-key" = "NOTIFY_COMMENT";
	};
	badge = 14;
 };
 photoId = 62465560603;
*/

	NSDictionary *aps = [notification objectForKey:@"aps"];
	NSDictionary *alert = [aps objectForKey:@"alert"];
	NSString *locKey = [alert objectForKey:@"loc-key"];
	NSArray *locArgs = [alert objectForKey:@"loc-args"];

	EventModel *event = [[EventModel alloc] init];

	event.albumIdHint = [notification objectForKey:@"albumId"];

	if ( [locKey isEqualToString:@"NOTIFY_COMMENT"] )
	{
		event.predicateType = @"COMMENT";
		event.subjectName = [locArgs objectAtIndex:0];
		event.objectType = @"PHOTO";
		event.objectId = [notification objectForKey:@"photoId"];
	}
	else if ( [locKey isEqualToString:@"NOTIFY_LIKE"] )
	{
		event.predicateType = @"LIKE";
		event.subjectName = [locArgs objectAtIndex:0];
		event.objectType = @"PHOTO";
		event.objectId = [notification objectForKey:@"photoId"];
	}
	else if ( [locKey isEqualToString:@"NOTIFY_PHOTO"] )
	{
		event.predicateType = @"UPLOADCOMPLETE";
	}
	else if ( [locKey isEqualToString:@"NOTIFY_JOIN"] )
	{
		event.predicateType = @"REDEEM";
	}
	else
	{
		NSLog( @"EventNavigationController navigateToNotification could not map locKey %@ to predicateType", locKey );
	}

	[self navigateToEvent:event];

	[event release];
}

- (void)didModelLoad:(EventDetailAlbumModel *)model;
{
	// When the event service returns the album ID we can use that value as the albumIdHint and take the user
	// to their desired destination
	_navigationEvent.albumIdHint = model.albumId;
	TT_RELEASE_SAFELY(_eventDetailAlbumModel);
	[self navigateToEvent:_navigationEvent];
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_eventDetailAlbumModel);
	[super dealloc];
}


@end
