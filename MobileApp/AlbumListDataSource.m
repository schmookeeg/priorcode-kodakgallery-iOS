//
//  EventAlbumListTTListDataSource.m
//  MobileApp
//
//  Created by Jon Campbell on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Three20/Three20+Additions.h>
#import "AlbumListDataSource.h"

@implementation AlbumListDataSource
@synthesize hideEmpty = _hideEmpty;
@synthesize visibleAlbums = _visibleAlbums;


- (id)initWithFilterAlbumType:(NSNumber *)filterAlbumType
{
	self = [super init];
	_isLoaded = NO;
    _hideEmpty = NO;
	self.filterAlbumType = filterAlbumType;
	[self.albumList setDelegate:self];

	return self;
}

- (id)init
{
	return [self initWithFilterAlbumType:[NSNumber numberWithInt:kAllAlbumType]];
}

- (AlbumListModel *)albumList
{
	return [AlbumListModel albumList];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	[super load:cachePolicy more:more];
	_isLoaded = NO;
	self.albumList.delegate = self;
	[self.albumList fetch];
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
	[_delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];
}


- (NSNumber *)filterAlbumType
{
	return _filterAlbumType;
}

- (void)setFilterAlbumType:(NSNumber *)filterAlbumType
{
	[_filterAlbumType release];
	_filterAlbumType = filterAlbumType;
	[_filterAlbumType retain];

	if ( _isLoaded )
	{
		[self populateDataSourceFromModel];
	}
}

- (void)clearFilterAlbumType
{
	[self setFilterAlbumType:nil];
}

- (void)populateDataSourceFromModel
{
	_isLoaded = YES;

	NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *visibleAlbumsArray = [NSMutableArray array];


	for ( AbstractAlbumModel *album in [self.albumList albums] )
	{

        if (_hideEmpty && [album.photoCount intValue] == 0) {
            continue;
        }

		if ( _filterAlbumType != nil && [_filterAlbumType intValue] != kAllAlbumType && ![_filterAlbumType isEqualToNumber:[album type]] )
		{
			continue;
		}
		NSString *img = [[album firstPhoto] thumbUrl];
		if ( img == nil )
		{
			img = [NSString stringWithFormat:@"bundle://%@", kAssetEmptyAlbumImage];
		}
		NSString *url = [NSString stringWithFormat:@"tt://album/%@", [album albumId]];

		UIImage *loadingImage = [UIImage imageNamed:kAssetLoadingImage];

		TTTableSubtitleItem *item = [TTTableSubtitleItem itemWithText:album.name
															 subtitle:[NSString stringWithFormat:@"%@ photos", album.photoCount]
															 imageURL:img
														 defaultImage:loadingImage
																  URL:url accessoryURL:nil];
		[array insertObject:item atIndex:[array count]];
        [visibleAlbumsArray insertObject:album atIndex:visibleAlbumsArray.count];
    }

    self.visibleAlbums = visibleAlbumsArray;
	[self setItems:array];

}

///////////////////////////////////////////////////////////////////////////////////////////////////
///  Overriden member of TTTableViewDataSource
- (UIImage *)imageForEmpty
{
	return [UIImage imageNamed:@"emptyAlbumImage.png"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///  Overriden member of TTTableViewDataSource
- (NSString *)titleForEmpty
{
	NSString *title;
	title = @"No Album Found";

	return title;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///  Overriden member of TTTableViewDataSource
- (NSString *)subtitleForEmpty
{
	NSString *subtitle;
	// STABTWO-1523 "Message in empty search is wrong."
	subtitle = @"\n\n";
	/* subtitle = @"There are no albums to view in this account, but you can fix that!\n\nSign into an existing account with the button in the upper left or create a new album in this account with the button in the upper right.";
*/
	return subtitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	UITableViewCell *tableCell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	if ( [tableCell isKindOfClass:[TTTableSubtitleItemCell class]] )
	{
		// We wish to have the album thumbnail clipped to a square image.  The default image representation
		// will force the whole image to appear in the thumbnail skewing the aspect ratio.   Here we take the
		// UIImage that will appear in the table cell and set it's contentMode and clipToBounds to properly clip the image
		TTTableSubtitleItemCell *subTitleCell = (TTTableSubtitleItemCell *) tableCell;
		TTImageView *image = [subTitleCell imageView2];
		image.contentMode = UIViewContentModeScaleAspectFill;
		image.clipsToBounds = YES;

		// STABTWO-1369 - Long album names should truncate instead of appearing in a smaller font size.
		subTitleCell.textLabel.adjustsFontSizeToFitWidth = NO;
	}

	return tableCell;
}

- (NSDate *)loadedTime;
{
	return self.albumList.populateTime;
}

- (NSMutableArray *)delegates
{
	if ( nil == _delegates )
	{
		_delegates = TTCreateNonRetainingArray();
	}
	return _delegates;
}


- (void)dealloc
{
	[_delegates release];
	[self clearFilterAlbumType];

    [_visibleAlbums release];
    [super dealloc];
}

/*-(id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
*/

/**********************************************************************************
 Changes:added functions for searching album 
 Date: 07-Sep-11
 Author: Diaspark Inc.
 *************************************************************************************/
- (void)search:(NSString *)text
{
	NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"FILTERKEY"];
	_filterAlbumType = num;

	NSMutableArray *array = [NSMutableArray array];
	[self populateDataSourceFromModel];
	if ( text.length )
	{
		text = [text lowercaseString];
		for ( TTTableTextItem *item in self.items )
		{
			NSString *albumName = item.text;
			if ( [[albumName lowercaseString] rangeOfString:text].location != NSNotFound )
			{
				[array addObject:item];
			}
		}
		[self setItems:array];
	}
	[_delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];
}
//end

@end
