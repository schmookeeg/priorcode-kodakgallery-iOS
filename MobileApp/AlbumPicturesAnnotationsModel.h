//
//  AlbumPicturesAnnotationModel.h
//  MobileApp
//
//  Created by mikeb on 7/20/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AbstractModel.h"
#import "AlbumPicturesAnnotationsModelDelegate.h"
#import "PictureAnnotationModel.h"

@interface AlbumPicturesAnnotationsModel : NSObject
{
	NSArray *_annotations;
	NSNumber *_photoId;
	id <AlbumPicturesAnnotationsModelDelegate> _delegateOverride;
	RKRequest *_request;
}

- (PictureAnnotationModel *)annotationForCurrentUser;

- (void)toggleLike;

- (void)likePhoto;

- (void)unlikePhoto;

@property ( nonatomic, assign ) id <AlbumPicturesAnnotationsModelDelegate> delegate;
@property ( retain, nonatomic ) NSArray *annotations;
@property ( retain, nonatomic ) NSNumber *photoId;
@property ( retain, nonatomic ) RKRequest *request;


@end
