//
//  NotificationTableItem.m
//  MobileApp
//
//  Created by Jon Campbell on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotificationTableItem.h"


@implementation NotificationTableItem

@synthesize avatarImage = _avatarImage;
@synthesize isLike = _isLike;

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
	self.avatarImage = nil;

	[super dealloc];
}

@end
