//
//  EventAlbumPhotoSource.m
//  MobileApp
//
//  Created by Dev on 6/1/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "AlbumPhotoSource.h"
#import "AlbumListModel.h"

static BOOL _albumDirty;

@implementation AlbumPhotoSource
@synthesize title = _title;
@synthesize photos = _photos;
@synthesize album = _album;
@synthesize albumAnnotations = _albumAnnotations;
@synthesize albumNotAccessible = _albumNotAccessible;

- (id)initWithAlbumId:(NSNumber *)albumId
{
	self = [super init];

	if ( self )
	{
		NSLog( @"AlbumPhotoSource initWithAlbumId" );

		_albumNotAccessible = NO;
		_isLoaded = NO;

		AbstractAlbumModel *albumListAlbum = [[AlbumListModel albumList] albumFromAlbumId:albumId];

		// If the album is not album list, it means that it has been deleted and the
		// user cannot access it anymore or that we're asking for a new albumId (from a notification)
        // that isn't in the user's album list because they haven't refreshed lately.
		// See https://jc.ofoto.com/jira/browse/STABTWO-1941
		if ( albumListAlbum == nil )
		{
			_albumNotAccessible = YES;
		}
		else
		{
			// Can't fetch directly into the album we got from the albumList because the fetch will
			// overwrite the albumType.  This presents a tricky scenario - we actually load the details
			// for an album NOT in the album list.  That means if we want to reference those album
			// details elsewhere (like the list of photos), we can't.  To get around this, we populate
			// the photos of the albumListAlbum with the photos of the album we fetch into in the
			// didModelLoad: method.
			id albumModelClass = [albumListAlbum class];
			self.album = [[[albumModelClass alloc] init] autorelease];
			self.album.albumId = albumId;
			self.album.groupId = albumListAlbum.groupId;
			self.album.delegate = self;
			[self.album fetch];
		}
	}
	return self;
}

- (void)refresh
{
	self.album.delegate = self;
	[self.album fetch];
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_title)
	TT_RELEASE_SAFELY(_photos)
	TT_RELEASE_SAFELY(_album)
	TT_RELEASE_SAFELY(_albumAnnotations)

	[super dealloc];
}

- (void)didModelLoad:(AbstractModel *)model;
{
	if ( [model isKindOfClass:[AbstractAlbumModel class]] )
	{
		// Loaded event album model
		_isLoaded = YES;

		// TRICKY: Because our self.album (_album) reference is *NOT* the same reference
		// as what's in the album list, we need to make sure that we populate the photo
		// information of the album-list album with the same photos that we just loaded.
		AbstractAlbumModel *albumListAlbum = [[AlbumListModel albumList] albumFromAlbumId:self.album.albumId];
		albumListAlbum.photos = self.album.photos;

        self.photos = _album.photos;
        for ( NSUInteger i = 0; i < _photos.count; ++i )
		{
			id <TTPhoto> photo = [_photos objectAtIndex:i];
			if ( (NSNull *) photo != [NSNull null] )
			{
				photo.photoSource = self;
				photo.index = i;
			}
		}
        self.title = _album.name;

		// Tell Three20 to display it
		[_delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];

		// Now fetch the related annotations for this model if we don't have them yet.
        self.albumAnnotations = [[[AlbumAnnotationsModel alloc] init] autorelease];
        self.albumAnnotations.delegate = self;
        [self.albumAnnotations fetchWithAlbumId:self.album.albumId];
	}
	else if ( [model isKindOfClass:[AlbumAnnotationsModel class]] )
	{
		NSLog( @"Annotations fetched" );
        
        // Once the annotations are fetched, we need to make sure the view can sync
        // to the proper number of comment and like counts.
		[_delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];

		// FIXME: The below is probably a better approach to this, but isn't quite bullet proof
		// yet (requires various view updates) and making this change just before v2.1 goes out
		// isn't a good idea.
		//
        // This doesn't check whether or not the object actually responds to the selector, so to
        // prevent a crash we can do the enumeration ourselves
        //[_delegates makeObjectsPerformSelector:@selector(annotationsDidFinishLoad:) withObject:model];
//		for ( id obj in _delegates )
//		{
//			if ([obj respondsToSelector:@selector(annotationsDidFinishLoad:)])
//			{
//				[obj performSelector:@selector(annotationsDidFinishLoad:) withObject:model];
//			}
//		}
	}
}

#pragma mark TTModel

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	_isLoaded = NO;

	[_album setDelegate:self];
	[_album fetch];

	NSLog( @"In load method - more: %c", more );
	[super load:cachePolicy more:more];
}

- (BOOL)isLoading
{
	return !_isLoaded;
}

- (BOOL)isLoaded
{
	return _isLoaded;
}

#pragma mark TTPhotoSource

- (NSInteger)numberOfPhotos
{
	return _photos.count;
}

- (NSInteger)maxPhotoIndex
{
	return _photos.count - 1;
}

- (id <TTPhoto>)photoAtIndex:(NSInteger)photoIndex
{
	if ( photoIndex < _photos.count )
	{
		return [_photos objectAtIndex:photoIndex];
	}
	else
	{
		return nil;
	}
}

- (NSDate *)loadedTime;
{
	return _album.populateTime;
}


+ (BOOL)albumDirty
{
	return _albumDirty;
}

+ (void)setAlbumDirty:(BOOL)dirtyFlag
{
	_albumDirty = dirtyFlag;
}

@end
