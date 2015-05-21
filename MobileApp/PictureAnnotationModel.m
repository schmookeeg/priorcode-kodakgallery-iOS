//
//  PictureAnnotationsModel.m
//  MobileApp
//
//  Created by Dev on 7/20/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "PictureAnnotationModel.h"
#import "ISO8601DateFormatter.h"

@implementation PictureAnnotationModel
@synthesize annotationId = _annotationId, annotatorId = _annotatorId;

- (NSDate *)timeStamp;
{
	return _timeStamp;
}

- (void)setTimeStamp:(NSString *)dateString
{

	[_timeStamp release];

	if ( dateString == nil )
	{
		return;
	}

	ISO8601DateFormatter *dateFormatter = [[[ISO8601DateFormatter alloc] init] autorelease];
	_timeStamp = [dateFormatter dateFromString:dateString];

	[_timeStamp retain];
}

- (void)setTimeStampWithDate:(NSDate *)date
{
	[_timeStamp release];
	_timeStamp = date;
	[_timeStamp retain];
}

- (NSString *)annotatorAvatarUrl
{
	NSString *avatarUrl = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [NSString stringWithFormat:kServiceUserAvatar, self.annotatorId]];
	return avatarUrl;
}

- (BOOL)isAnonymous
{
	return ( [_annotatorName rangeOfString:@"anon"].location != NSNotFound );
}

- (NSString *)annotatorName
{
	return ( [self isAnonymous] ) ? NSLocalizedString( @"GuestUser", nil ) : _annotatorName;
}

- (void)setAnnotatorName:(NSString *)annotatorName
{
	[annotatorName retain];
	[_annotatorName release];
	_annotatorName = annotatorName;
}

- (void)dealloc
{
	[self setTimeStampWithDate:nil];

	[_annotatorId release];
	[_annotatorName release];
	[_annotationId release];

	[super dealloc];
}


@end
