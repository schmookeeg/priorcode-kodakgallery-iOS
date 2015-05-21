//
//  EventModel.m
//  MobileApp
//
//  Created by Darron Schall on 9/15/11.
//

#import "EventModel.h"
#import "ISO8601DateFormatter.h"

@implementation EventModel

@synthesize eventId, eventLink;

@synthesize subjectType, subjectId, subjectName, subjectIcon;

@synthesize objectType, objectId, objectName, objectIcon, objectOwnerId, objectOwnerName;

@synthesize predicateType;

@synthesize albumIdHint;

@synthesize publisherId;

- (void)dealloc
{
	self.eventId = nil;
	self.eventLink = nil;

	self.subjectType = nil;
	self.subjectId = nil;
	self.subjectName = nil;
	self.subjectIcon = nil;

	self.objectType = nil;
	self.objectId = nil;
	self.objectName = nil;
	self.objectIcon = nil;
	self.objectOwnerId = nil;
	self.objectOwnerName = nil;

	self.predicateType = nil;

	[_time release];

	self.albumIdHint = nil;

	self.publisherId = nil;

	[super dealloc];
}

- (NSString *)checkForGuest:(NSString *)name
{
    if ( [name rangeOfString:@"anon"].location != NSNotFound ) 
    {
        return NSLocalizedString( @"GuestUser", nil );
    }
    else
    {
        return name;
    }
}

- (NSString *)sanitizedSubjectName
{ 
    NSString *subName = [self checkForGuest:self.subjectName];
    return subName;
}

- (NSString *)friendlyDescription
{
	// These string formats correspond to the NOTIFY_* values in the Localizable.strings file.

    self.objectOwnerName = [self checkForGuest:self.objectOwnerName];

	if ( [self.predicateType isEqualToString:@"COMMENT"] )
	{
		return [NSString stringWithFormat:@"Commented on %@'s photo.", self.objectOwnerName];
	}
	else if ( [self.predicateType isEqualToString:@"LIKE"] )
	{
		return [NSString stringWithFormat:@"Liked %@'s photo.", self.objectOwnerName];
	}
	else if ( [self.predicateType isEqualToString:@"UPLDCOMPLETE"] )
	{
		return [NSString stringWithFormat:@"Added photos to album \"%@\".", self.objectName];
	}
	else if ( [self.predicateType isEqualToString:@"REDEEM"] )
	{
		return [NSString stringWithFormat:@"Joined album \"%@\".", self.objectName];
	}
	else if ( [self.predicateType isEqualToString:@"SHARE"] )
	{
		return [NSString stringWithFormat:@"Shared album \"%@\".", self.objectName];
	}


	NSLog( @"EventModel friendlyDescription needs case for predicateType: %@", self.predicateType );

	return nil;
}

- (NSString *)displayImage
{
	return self.objectIcon;
}

- (NSDate *)time;
{
	return _time;
}

- (void)setTimeFromDate:(NSDate *)date
{

	[_time release];
	_time = date;
	[_time retain];

}

- (void)setTime:(NSString *)dateString;
{
	[_time release];

	if ( !dateString )
	{
		return;
	}

	ISO8601DateFormatter *dateFormatter = [[[ISO8601DateFormatter alloc] init] autorelease];
	_time = [dateFormatter dateFromString:dateString];
	[_time retain];
}

@end
