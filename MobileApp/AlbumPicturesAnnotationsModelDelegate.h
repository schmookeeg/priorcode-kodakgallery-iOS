//
//  AlbumPicturesAnnotationsModelDelegate.h
//  MobileApp
//
//  Created by mikeb on 7/26/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractModelDelegate.h"

@class AlbumPicturesAnnotationsModel;

@protocol AlbumPicturesAnnotationsModelDelegate <AbstractModelDelegate>

@optional
- (void)didLikeSucceed:(AlbumPicturesAnnotationsModel *)model;

- (void)didLikeFail:(AlbumPicturesAnnotationsModel *)model  error:(NSError *)error;

- (void)didUnLikeSucceed:(AlbumPicturesAnnotationsModel *)model;

- (void)didUnLikeFail:(AlbumPicturesAnnotationsModel *)model  error:(NSError *)error;;


@end
