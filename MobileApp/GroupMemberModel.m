//
//  GroupMemberModel.m
//  MobileApp
//
//  Created by Jon Campbell on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupMemberModel.h"

@implementation GroupMemberModel


@synthesize email = _email;
@synthesize role = _role;
@synthesize status = _status;
@synthesize memberAvatarLink = _memberAvatarLink;
@synthesize joinDate = _joinDate;
@synthesize uploadCount = _uploadCount;

- (id)init
{
	self = [super init];
	if ( self )
	{
		// Initialization code here.
	}

	return self;
}

- (BOOL)isAnonymous
{
	return ( [_firstName rangeOfString:@"anon"].location != NSNotFound );
}

- (void)setFirstName:(NSString *)name
{
	[_firstName release];

	_firstName = name;

	[_firstName retain];
}

- (NSString *)firstName
{
    return ( [self isAnonymous] ) ? NSLocalizedString( @"GuestUser", nil ) : _firstName;
}

- (void)dealloc
{
	[_firstName release];
	[_email release];
	[_role release];
	[_status release];
	[_memberAvatarLink release];
	[_joinDate release];
	[_uploadCount release];

	[super dealloc];
}

@end
