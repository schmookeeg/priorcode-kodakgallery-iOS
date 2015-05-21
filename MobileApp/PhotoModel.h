//
//  PhotoModel.h
//  MobileDemo
//
//  Created by Jon Campbell on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <Three20/Three20.h>
#import "AbstractModel.h"
#import "PhotoModelDelegate.h"
#import "DDXML.h"
#import "ShareModel.h"

@interface PhotoModel : AbstractModel <TTPhoto, ShareModel>
{
	NSNumber *_photoId;
	NSNumber *_partitionId;
	NSNumber *_width;
	NSNumber *_height;
	NSString *_albUrl;
	NSString *_sumoUrl;
	NSString *_bgUrl;
	NSString *_smUrl;
	NSString *_fullResUrl;
	NSString *_uploaderName;
	NSNumber *_ownerId;
	NSString *_caption;
	id <TTPhotoSource> _photoSource;
	CGSize _size;
	NSInteger _index;
	NSNumber *_numComments;
	NSNumber *_numLikes;
	NSMutableArray *_likes;
	NSNumber *_uploaderId;
	id <PhotoModelDelegate> _delegateOverride;
    BOOL _selected;

}

- (NSString *)thumbUrl;

- (NSString *)thumbUrlAlternate;

- (NSDictionary *)serializeToDictionary;

- (void)downloadFullResolutionPhoto;

- (void)deletePhotoFromAlbum:(NSNumber *)albumId;

- (void)rotateLeftInAlbum:(NSNumber *)albumId;

- (void)rotateRightInAlbum:(NSNumber *)albumId;

@property ( retain, nonatomic ) NSNumber *photoId;
@property ( retain, nonatomic ) NSNumber *partitionId;
@property ( retain, nonatomic ) NSNumber *width;
@property ( retain, nonatomic ) NSNumber *height;
@property ( retain, nonatomic ) NSString *albUrl;
@property ( retain, nonatomic ) NSString *sumoUrl;
@property ( retain, nonatomic ) NSString *bgUrl;
@property ( retain, nonatomic ) NSString *smUrl;
@property ( retain, nonatomic ) NSString *uploaderName;
@property ( retain, nonatomic ) NSNumber *ownerId;
@property ( nonatomic, copy ) NSString *caption;
@property ( nonatomic, assign ) id <TTPhotoSource> photoSource;
@property ( nonatomic ) CGSize size;
@property ( nonatomic ) NSInteger index;
@property ( retain, nonatomic ) NSNumber *numComments;
@property ( retain, nonatomic ) NSNumber *numLikes;
@property ( retain, nonatomic ) NSNumber *uploaderId;
@property ( nonatomic, assign ) id <PhotoModelDelegate> delegate;
@property ( retain, nonatomic ) NSString *fullResUrl;
@property(nonatomic, assign) BOOL selected;


@end
