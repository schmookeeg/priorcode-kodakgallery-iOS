//
//  FriendsAlbumModel.m
//  MobileApp
//
//  Created by Jon Campbell on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendsAlbumModel.h"
#import "ShareTokenList.h"

@implementation FriendsAlbumModel

+ (NSString *)menuTitle
{
	return @"Friends' Albums";
}

+ (NSString *)menuIcon
{
	return kAssetFriendAlbumsIcon;
}

- (id)initWithAlbum:(AbstractAlbumModel *)album
{
	self = [super initWithAlbum:album];
	self.type = [NSNumber numberWithInt:kFriendAlbumType];

	return self;
}

- (id)init
{
	self = [super init];
	if ( self )
	{
		self.type = [NSNumber numberWithInt:kFriendAlbumType];
	}

	return self;
}

- (int)enabledOptions
{
	return kAlbumTypeEnabledOptionsFriendAlbum;
}

- (void)join
{

	NSString *url = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kServiceRedeemAlbum];
	if ( self.shareToken == nil )
	{
		self.shareToken = [ShareTokenList tokenForAlbumId:self.albumId];
	}
	NSString *urlString = [NSString stringWithFormat:url, self.shareToken];
	RKRequest *request = [RKRequest requestWithURL:[NSURL URLWithString:urlString] delegate:self];
	[request setMethod:RKRequestMethodPOST];

	NSDictionary *headers = [NSMutableDictionary dictionary];
	[headers setValue:@"text/xml" forKey:@"Content-Type"];
	[request setAdditionalHTTPHeaders:headers];

	NSData *data = [[NSString stringWithString:@""] dataUsingEncoding:NSUTF8StringEncoding];
	[request.URLRequest setHTTPBody:data];

	[request setUserData:@"redeemAlbumRequest"];
	[request send];
}

- (void)deleteAlbum
{
	[self deleteAlbumUsingUrl:kServiceFriendsAlbum usingId:self.albumId];
}

@end
