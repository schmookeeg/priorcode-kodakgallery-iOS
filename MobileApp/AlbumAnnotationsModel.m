//
//  AlbumAnnotationsModel.m
//  MobileApp
//
//  Created by Peter Traeg on 7/20/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "AlbumAnnotationsModel.h"

static NSArray *_picturesAnnotations;

@implementation AlbumAnnotationsModel

- (NSString *)url {
    return [NSString stringWithFormat:kServiceAlbumAnnotations, _albumId];
}


- (void)fetchWithAlbumId:(NSNumber *)albumId
{
	self.albumId = albumId;

	[self fetch];
}

+ (AlbumPicturesAnnotationsModel *)annotationsForPhotoId:(NSNumber *)photoId createIfNil:(BOOL)createIfNil
{
	for ( AlbumPicturesAnnotationsModel *pictureAnnotations in _picturesAnnotations )
	{
		if ( [[pictureAnnotations photoId] isEqual:photoId] )
		{
			return pictureAnnotations;
		}
	}

	if ( createIfNil )
	{
		// There are no annotations yet, so create one
		AlbumPicturesAnnotationsModel *model = [[[AlbumPicturesAnnotationsModel alloc] init] autorelease];
		model.photoId = photoId;
		model.annotations = [NSArray array];
		[AlbumAnnotationsModel setPicturesAnnotationsStatic:[[AlbumAnnotationsModel picturesAnnotationsStatic] arrayByAddingObject:model]];

		return model;
	}

	return nil;
}

+ (BOOL)userLikesPhoto:(NSNumber *)photoId
{
    AlbumPicturesAnnotationsModel *photoAnnotations = [AlbumAnnotationsModel annotationsForPhotoId:photoId createIfNil:NO];
    if ( photoAnnotations != nil )
    {
        PictureAnnotationModel *pictureAnnotation = [photoAnnotations annotationForCurrentUser];
        if ( pictureAnnotation != nil )
        {
            // User already likes this picture
            return YES;
        }
    }
    
    return NO;
}

- (NSArray *)picturesAnnotations
{
	return [AlbumAnnotationsModel picturesAnnotationsStatic];
}

- (void)setPicturesAnnotations:(NSArray *)annotations
{
	[AlbumAnnotationsModel setPicturesAnnotationsStatic:annotations];
}

+ (NSArray *)picturesAnnotationsStatic
{
	return _picturesAnnotations;
}

+ (void)setPicturesAnnotationsStatic:(NSArray *)annotations
{
	[annotations retain];
	[_picturesAnnotations release];
	_picturesAnnotations = annotations;
}

- (NSNumber *)albumId
{
	return _albumId;
}

- (void)setAlbumId:(NSNumber *)albumId
{
	[albumId retain];
	[_albumId release];
	_albumId = albumId;
}

- (void)dealloc
{
	// TODO This is a static property that we should only release if
	// we know we're the last instance being destroyed
	//[_picturesAnnotations release];
	//_picturesAnnotations = nil;

	[_albumId release];

	[super dealloc];
}

#pragma mark RKRequestDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
	[super objectLoader:objectLoader didLoadObjects:objects];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
	[super objectLoader:objectLoader didFailWithError:error];
}

@end
