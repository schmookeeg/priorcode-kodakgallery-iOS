//
//  PhotoModelDelegate.h
//  MobileApp
//
//  Created by Diaspark Inc. on 12/10/11.
//  Copyright 2011 Diaspark Inc. All rights reserved.
//

#import "AbstractModelDelegate.h"

@class PhotoModel;

@protocol PhotoModelDelegate <AbstractModelDelegate>

@optional

- (void)photoDownloadDidSucceedWithModel:(PhotoModel *)model;

- (void)photoDownloadDidFailWithError:(NSError *)error;

- (void)photoDeletionDidSucceedWithModel:(PhotoModel *)model;

- (void)photoDeletionDidFailWithError:(NSError *)error;

- (void)photoRotationDidSucceedWithModel:(PhotoModel *)model;

- (void)photoRotationDidFailWithError:(NSError *)error;

@end
