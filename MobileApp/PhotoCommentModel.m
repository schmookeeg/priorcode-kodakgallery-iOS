//
//  PhotoCommentModel.m
//  MobileApp
//
//  Created by Dev on 6/22/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "PhotoCommentModel.h"
#import "ISO8601DateFormatter.h"

@implementation PhotoCommentModel
@synthesize commentId = _commentId, photoId = _photoId, authorId = _authorId, email = _email;
@synthesize text = _text;

+ (NSString *)primaryKeyProperty
{
	return @"commentId";
}

- (NSDate *)lastUpdated;
{
	return _lastUpdated;
}

- (void)setLastUpdated:(NSString *)dateString;
{

	[_lastUpdated release];

	ISO8601DateFormatter *dateFormatter = [[[ISO8601DateFormatter alloc] init] autorelease];
	_lastUpdated = [dateFormatter dateFromString:dateString];

	[_lastUpdated retain];
}

- (NSString *)authorAvatarUrl
{
	NSString *avatarUrl = [NSString stringWithFormat:@"%@/site/rest/v1.0/user/%@/avatar/jpeg", kRestKitBaseUrl, self.authorId];
	return avatarUrl;
}

- (BOOL)isAnonymous
{
	return ( [_author rangeOfString:@"anon"].location != NSNotFound );
}

- (NSString *)author
{
	return ( [self isAnonymous] ) ? NSLocalizedString( @"GuestUser", nil ) : _author;
}

- (void)setAuthor:(NSString *)author
{
	[_author release];
	_author = author;
	[_author retain];
}


- (void)dealloc
{

	[_photoId release];
	[_commentId release];
	[_authorId release];
	[_author release];
	[_email release];
	[_lastUpdated release];
	[_text release];

	[super dealloc];
}


@end
