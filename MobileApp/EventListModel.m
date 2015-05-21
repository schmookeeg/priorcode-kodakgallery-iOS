//
//  EventListModel.m
//  MobileApp
//
//  Created by Darron Schall on 9/15/11.
//

#import "EventListModel.h"

@implementation EventListModel

@synthesize events = _events;
@synthesize unreadEventsCount;

#pragma mark Object Lifecycle
- (id)init
{
	self = [super init];
	if ( self )
	{
		// Initialization code here.
	}

	return self;
}

- (void)dealloc
{
	self.events = nil;
	self.unreadEventsCount = nil;

	[super dealloc];
}

#pragma mark -

- (void)fetch
{
	[self fetchUsingDelegate:self clearBadgeCount:YES];
}

- (void)fetchUsingDelegate:(id <RKObjectLoaderDelegate>)objectLoaderDelegate clearBadgeCount:(BOOL)clear
{
	RKObjectManager *objectManager = [RKObjectManager sharedManager];
	RKObjectLoader *loader = [objectManager objectLoaderWithResourcePath:kServiceEventList delegate:objectLoaderDelegate];

	if ( clear )
	{
		loader.method = RKRequestMethodPOST;
	}
	else
	{
		loader.method = RKRequestMethodGET;
	}


	loader.targetObject = self;
	[loader send];
}

#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
	[super objectLoader:objectLoader didLoadObjects:objects];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
	[super objectLoader:objectLoader didFailWithError:error];
}

@end
