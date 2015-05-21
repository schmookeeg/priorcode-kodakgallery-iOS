//
//  EventAlbumListModel.m
//  MobileApp
//
//  Created by Jon Campbell on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumListModel.h"
#import "EventAlbumModel.h"
#import "MyAlbumModel.h"
#import "FriendsAlbumModel.h"

@implementation AlbumListModel
@synthesize delegate = _delegateOverride;

/*
+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:                          
            nil];
}

+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"EventAlbum", @"eventAlbums",
            nil];
}
 */

- (id)init
{
	self = [super init];

	if ( self )
	{
		_currentJoinIndex = -1;
		_albums = nil;
		return self;
	}

	return nil;;
}

- (NSString *) url {
    return kServiceAllAlbumList;
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
	[super objectLoader:objectLoader didLoadObjects:objects];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
	[super objectLoader:objectLoader didFailWithError:error];
}


- (void)dealloc
{
	[_albums release];
	[super dealloc];
}

+ (AlbumListModel *)albumList
{
	static dispatch_once_t pred;
	static AlbumListModel *currentAlbumListModel = nil;

	dispatch_once(&pred, ^
	{
		currentAlbumListModel = [[AlbumListModel alloc] init];
	});

	return currentAlbumListModel;
}


- (void)joinAllAlbums
{
	if ( [_albums count] == 0 )
	{
		_currentJoinIndex = -1;
		if ( [self.delegate respondsToSelector:@selector(didJoinAllSucceed:)] )
		{
			[self.delegate didJoinAllSucceed:self];
		}
		return;
	}


	_currentJoinIndex = 0;

	[self joinAlbum];
}

- (void)joinAlbum
{

	if ( _currentJoinIndex >= [_albums count] )
	{
		if ( [self.delegate respondsToSelector:@selector(didJoinAllSucceed:)] )
		{
			[self.delegate didJoinAllSucceed:self];
		}

		return;
	}


	AbstractAlbumModel *album = [_albums objectAtIndex:_currentJoinIndex++];

	[album setDelegate:self];
	[album join];


}

- (void)didJoinSucceed:(AbstractAlbumModel *)model
{
	[self joinAlbum];
}

- (void)didJoinFail:(AbstractAlbumModel *)model error:(NSError *)error
{
	if ( [self.delegate respondsToSelector:@selector(didJoinAllFail:error:)] )
	{
		[self.delegate didJoinAllFail:self error:error];
	}

	_currentJoinIndex = -1;
}

- (AbstractAlbumModel *)albumFromAlbumId:(NSNumber *)albumId
{
	for ( AbstractAlbumModel *album in _albums )
	{
		if ( [album.albumId isEqualToNumber:albumId] )
		{
			return album;
		}
	}
	return nil;
}

- (NSArray *)albums
{
	return _albums;
}

- (void)setAlbums:(NSArray *)albums
{
    // TRICKY: In the AlbumPhotoSource, we copy the "photos" property from the album details
    // that have loaded onto the "photos" of the corresponding album in the album list (because
    // the details are actually loaded for a *separate* object instance, even though it has
    // the same album id).  Because we do this, we have to be careful when the albums property
    // is overwritten.  We need to preserve the photos array.
    //
    // Counts in the array are equal, check to see if every time points to the same reference
    if ( [_albums count] == [albums count] )
    {
        for ( NSUInteger i = 0; i < [_albums count]; i++ )
        {
            // We'll consider "equal" here as "same album id" and "in the same order"
            AbstractAlbumModel *existingAlbum = [_albums objectAtIndex:i];
            AbstractAlbumModel *newAlbum = [albums objectAtIndex:i];
            if ( [existingAlbum.albumId isEqualToNumber:newAlbum.albumId] )
            {
                // Copy the photos over that we've previously loaded for the exsitingAlbum
                newAlbum.photos = existingAlbum.photos;
            }
        }
    }

	if ( _albums != nil && ( [_albums count] > 0 ) )
	{
		[_albums release];
	}

	_albums = [[NSMutableArray alloc] init];

	for ( AbstractAlbumModel *album in albums )
	{
		AbstractAlbumModel *returnAlbum = nil;
		// we have to check this first as friend albums will also be event and my albums
		if ( [album isFriendAlbum] )
		{
			returnAlbum = [[FriendsAlbumModel alloc] initWithAlbum:album];
		}
		else if ( [album isEventAlbum] )
		{
			returnAlbum = [[EventAlbumModel alloc] initWithAlbum:album];
		}
		else if ( [album isMyAlbum] )
		{
			returnAlbum = [[MyAlbumModel alloc] initWithAlbum:album];
		}

		// STABTWO-1355 - If the returnAlbum was not able to be created, log a warning
		// and continue to the next album to prevent a crash.
		if ( returnAlbum == nil )
		{
			NSLog( @"AlbumListModel setAlbums: Skipping album named %@ because of unrecognized type %@", album.name, album.type );
		}
		else
		{

			[(NSMutableArray *) _albums addObject:returnAlbum];
			[returnAlbum release];

		}
	}
}


@end
