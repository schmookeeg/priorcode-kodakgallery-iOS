//
//  MemberListDataSource.m
//  MobileApp
//
//  Created by Jon Campbell on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MemberListDataSource.h"
#import "AlbumListModel.h"

@implementation MemberListDataSource

@synthesize eventAlbum = _eventAlbum;


- (id)initWithEventAlbum:(AbstractAlbumModel *)eventAlbum
{
	self = [super init];

	_isLoaded = NO;
	_eventAlbum = eventAlbum;

	if ( [_eventAlbum populated] )
	{
		[self populateDataSourceFromModel];
	}

	_anonymousUsers = 0;

	return self;
}

- (BOOL)isLoading
{
	return !_isLoaded;
}

- (BOOL)isLoaded
{
	return _isLoaded;
}

- (void)populateDataSourceFromModel
{
	_isLoaded = YES;

	NSMutableArray *array = [NSMutableArray array];
	AbstractAlbumModel *abstractModel = [[AlbumListModel albumList] albumFromAlbumId:[_eventAlbum albumId]];
	GroupMemberModel *founder = [abstractModel founder];

	NSString *img = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [founder memberAvatarLink]];
	NSString *uploadedText = [NSString stringWithFormat:@"%@ photo%@", [founder uploadCount], ( [[founder uploadCount] intValue] != 1 )
																							  ? @"s" : @""];

	TTTableSubtitleItem *item = [TTTableSubtitleItem itemWithText:[NSString stringWithFormat:@"%@ (Founder)", [founder firstName]] subtitle:uploadedText imageURL:img URL:nil];

	[array insertObject:item atIndex:[array count]];

	for ( GroupMemberModel *member in [_eventAlbum members] )
	{

		if ( [member isAnonymous] )
		{
			_anonymousUsers++;
			continue;
		}

		img = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, [member memberAvatarLink]];

		if ( [[member uploadCount] intValue] < 1 )
		{
			uploadedText = @"  ";
		}
		else
		{
			uploadedText = [NSString stringWithFormat:@"%@ photo%@", [member uploadCount], ( [[member uploadCount] intValue] != 1 )
																						   ? @"s" : @""];
		}

		item = [TTTableSubtitleItem itemWithText:[member firstName] subtitle:uploadedText imageURL:img URL:nil];


		[array insertObject:item atIndex:[array count]];
	}


	if ( _anonymousUsers > 0 )
	{
		TTTableTextItem *item = [TTTableTextItem itemWithText:[NSString stringWithFormat:@"%d guest members", _anonymousUsers]];
		[array insertObject:item atIndex:[array count]];
	}

	[self setItems:array];
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
