//
//  EventAlbumListTTListDataSource.m
//  MobileApp
//
//  Created by Jon Campbell on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadEventAlbumListDataSource.h"


@implementation UploadEventAlbumListDataSource
@synthesize albumList = _albumList;


- (id)init
{
	self = [super init];
	_isLoaded = NO;
	_albumList = [[AlbumListModel alloc] init];
	[_albumList setDelegate:self];
	return self;
}


- (id)initWithEventAlbumList:(AlbumListModel *)albumList
{
	_isLoaded = NO;

	self.albumList = albumList;
	[_albumList setDelegate:self];

	if ( [_albumList populated] )
	{
		[self populateDataSourceFromModel];
	}
	else
	{
		[_albumList fetch];
	}

	return self;
}

- (void)dealloc
{
	[_albumList release];
	[super dealloc];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	[super load:cachePolicy more:more];
	_isLoaded = NO;
	[_albumList fetch];
	[self.delegates makeObjectsPerformSelector:@selector(modelDidStartLoad:) withObject:self];
}

- (BOOL)isLoading
{
	return !_isLoaded;
}

- (BOOL)isLoaded
{
	return _isLoaded;
}

- (void)didModelLoad:(AbstractModel *)model;
{
	[self populateDataSourceFromModel];
	[self.delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)populateDataSourceFromModel
{
	_isLoaded = YES;

	NSMutableArray *array = [NSMutableArray array];

	for ( AbstractAlbumModel *eventAlbum in [_albumList albums] )
	{

		NSString *img = [[eventAlbum firstPhoto] smUrl];
		NSString *url = [NSString stringWithFormat:@"tt://upload/%@", [eventAlbum groupId]];

		TTTableImageItem *item = [TTTableImageItem itemWithText:[eventAlbum name] imageURL:img defaultImage:nil imageStyle:TTSTYLE(rounded) URL:url];


		item.imageStyle = [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill
													 size:CGSizeMake( 45, 45 ) next:nil];


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

/*-(id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return nil;
 }
 */



@end
