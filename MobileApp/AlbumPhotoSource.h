//
//  EventAlbumPhotoSource.h
//  MobileApp
//
//  Created by mikeb on 6/1/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"
#import <RestKit/RestKit.h>
#import "AlbumModelDelegate.h"
#import "AlbumAnnotationsModel.h"


@interface AlbumPhotoSource : TTURLRequestModel <TTPhotoSource, AlbumModelDelegate>
{
	NSString *_title;
	NSArray *_photos;
	AbstractAlbumModel *_album;
	AlbumAnnotationsModel *_albumAnnotations;
	BOOL _isLoaded;
	BOOL _albumNotAccessible;
}

@property ( nonatomic, copy ) NSString *title;
@property ( nonatomic, retain ) NSArray *photos;
@property ( nonatomic, retain ) AlbumAnnotationsModel *albumAnnotations;
@property ( nonatomic, retain ) AbstractAlbumModel *album;
@property ( nonatomic, readonly, getter = isAlbumNotAccessible ) BOOL albumNotAccessible;

+ (BOOL)albumDirty;

+ (void)setAlbumDirty:(BOOL)dirtyFlag;

- (id)initWithAlbumId:(NSNumber *)albumId;

- (void)refresh;

- (NSDate *)loadedTime;

@end
