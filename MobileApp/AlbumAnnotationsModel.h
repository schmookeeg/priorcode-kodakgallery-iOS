//
//  AlbumAnnotationsModel.h
//  MobileApp
//
//  Created by mikeb on 7/20/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AbstractModel.h"
#import "AbstractModelDelegate.h"
#import "AlbumPicturesAnnotationsModel.h"


@interface AlbumAnnotationsModel : AbstractModel <RKRequestDelegate>
{
	NSNumber *_albumId;
}

- (void)fetchWithAlbumId:(NSNumber *)albumId;

/* 
 These are here to be key-value-coding compliant for the 'picturesAnnotations' key.
 Implementation-wise they actually point to a static array.
 */
- (NSArray *)picturesAnnotations;

- (void)setPicturesAnnotations:(NSArray *)annotations;

- (NSNumber *)albumId;

- (void)setAlbumId:(NSNumber *)albumId;

+ (AlbumPicturesAnnotationsModel *)annotationsForPhotoId:(NSNumber *)photoId createIfNil:(BOOL)createIfNil;

+ (BOOL)userLikesPhoto:(NSNumber *)photoId;

+ (NSArray *)picturesAnnotationsStatic;

+ (void)setPicturesAnnotationsStatic:(NSArray *)annotations;

@end
