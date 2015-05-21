//
//  EventListDataSource.m
//  MobileApp
//
//  Created by Darron Schall on 9/15/11.
//

#import "EventListDataSource.h"
#import "EventModel.h"
#import "NotificationTableCell.h"
#import "NotificationTableItem.h"

@implementation EventListDataSource

@synthesize eventList = _eventList;

#pragma mark Object Lifecycle

- (id)init
{
	self = [super init];
	if ( self )
	{
		_isLoaded = NO;

		EventListModel *eventListModel = [[EventListModel alloc] init];
		eventListModel.delegate = self;
		self.eventList = eventListModel;
		[eventListModel release];

		[self.eventList fetch];
	}

	return self;
}

- (void)dealloc
{
    self.eventList.delegate = nil;
	self.eventList = nil;

	[super dealloc];
}

#pragma mark -

- (BOOL)isLoading
{
	return !_isLoaded;
}

- (BOOL)isLoaded
{
	return _isLoaded;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	[super load:cachePolicy more:more];
	_isLoaded = NO;
	[_eventList setDelegate:self];
	[_eventList fetch];
	[self.delegates makeObjectsPerformSelector:@selector(modelDidStartLoad:) withObject:self];
}


- (void)populateDataSourceFromModel
{
	_isLoaded = YES;

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];

	NSMutableArray *tItems = [NSMutableArray array];

	// Create a dummy url for the notification event so that the item in the table
	// gets the disclosure indicator.  We navigator to the "real" URL by overriding
	// the didSelectObject:atIndexPath: method.
	NSString *dummyURL = @"tt://albumList";

	for ( EventModel *event in _eventList.events )
	{
  		NotificationTableItem *item = [NotificationTableItem itemWithTitle:[event sanitizedSubjectName]
																   caption:[event friendlyDescription]
																	  text:nil timestamp:event.time
																  imageURL:event.displayImage
																	   URL:dummyURL];

		item.avatarImage = event.subjectIcon;
		item.isLike = [event.predicateType isEqualToString:@"LIKE"];


		[tItems insertObject:item atIndex:tItems.count];
	}

	[dateFormatter release];

	// Post a message so that the notification bar and application badge reset now that we're
	// showing all of the notifications in the notification view.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ClearUnreadRemoteNotifications"
														object:self
													  userInfo:nil];

	[self setItems:tItems];
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object
{
	// This forces TTableView to use our custom CommentTableCellView rather than 
	// loading different views based on the type of TableItem being passed in.
	return [NotificationTableCell class];
}


- (NSDate *)loadedTime;
{
	return _eventList.populateTime;
}

#pragma mark AbstractModelDelegate

- (void)didModelLoad:(AbstractModel *)model;
{
	[self populateDataSourceFromModel];

	// Force Three20 to update the display
	[_delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];
}

- (NSMutableArray *)delegates
{
	if ( nil == _delegates )
	{
		_delegates = TTCreateNonRetainingArray();
	}
	return _delegates;
}

@end
