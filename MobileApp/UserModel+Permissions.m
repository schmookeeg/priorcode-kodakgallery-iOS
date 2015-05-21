//
//  UserModel+Permissions.m
//  MobileApp
//
//  Created by Darron Schall on 11/9/11.
//  Copyright (c) 2011 Universal Mind, Inc. All rights reserved.
//

#import "UserModel+Permissions.h"
#import "EventAlbumModel.h"

@implementation UserModel (Permissions)

- (BOOL)canDownloadPhoto:(PhotoModel *)photo fromAlbum:(AbstractAlbumModel *)album
{
	NSNumber *uploaderOrOwnerId = [photo uploaderId];
	// uploaderId might be nil (in some my albums), so grab the ownerId to test for ownership
	if ( uploaderOrOwnerId == nil )
	{
	    uploaderOrOwnerId = [photo ownerId];
	}
	NSString *userId = [self sybaseId];

	int albumType = [album.type intValue];

	// Can download is permission is set
	// Can download any photo in a My Album
	// Can download any photo in a Group Album
	// Can download any photo uploaded by the user
	return [[album permission] intValue] > 0
			|| albumType == kMyAlbumType
			|| albumType == kEventAlbumType
			|| [uploaderOrOwnerId doubleValue] == [userId doubleValue];
}

- (BOOL)canEditAlbum:(AbstractAlbumModel *)album
{
	NSString *founderMail = [[album founder] email];
	NSString *userMail = [self email];

	// Can delete an album when the user is the founder (all album types), or
	// Can delete an album when the album is not an event album.
	return [founderMail isEqualToString:userMail] || ( ![album isKindOfClass:[EventAlbumModel class]] );
}

- (BOOL)canDeletePhoto:(PhotoModel *)photo inAlbum:(AbstractAlbumModel *)album
{
	NSNumber *uId = [photo uploaderId];
    // uploaderId might be nil (in some my albums), so grab the ownerId to test for ownership
    if ( uId == nil )
    {
        uId = [photo ownerId];
    }
	NSString *sId = [self sybaseId];

	if ( photo )
	{
		// Can delete photos uploaded by the user (all album types), or
		// Can delete any photo in a "My Album"
		return [uId doubleValue] == [sId doubleValue] || [album.type intValue] == kMyAlbumType;
	}

	return NO;
}

- (BOOL)canRotatePhoto:(PhotoModel *)photo inAlbum:(AbstractAlbumModel *)album
{
	NSNumber *uId = [photo uploaderId];
    // uploaderId might be nil (in some my albums), so grab the ownerId to test for ownership
    if ( uId == nil )
    {
        uId = [photo ownerId];
    }
	NSString *sId = [self sybaseId];

	if ( photo )
	{
		// Can rotate if you own them in your own album
		// Or, any photo in a group album
		return ( [uId doubleValue] == [sId doubleValue] && [album.type intValue] == kMyAlbumType )
				|| [album.type intValue] == kEventAlbumType;
	}

	return NO;
}

@end
