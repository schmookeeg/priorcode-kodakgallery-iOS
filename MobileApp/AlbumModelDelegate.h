//
//  EventAlbumModelDelegate.h
//  MobileApp
//
//  Created by Jon Campbell on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractModelDelegate.h"

@class AbstractAlbumModel;

@protocol AlbumModelDelegate <AbstractModelDelegate>

@optional

- (void)didCreateSucceed:(AbstractAlbumModel *)model albumId:(NSNumber *)albumId;

- (void)didCreateFail:(AbstractAlbumModel *)model error:(NSError *)error;

- (void)didEditSucceed:(AbstractAlbumModel *)model;

- (void)didEditFail:(AbstractAlbumModel *)model error:(NSError *)error;

- (void)didJoinSucceed:(AbstractAlbumModel *)model;

- (void)didJoinFail:(AbstractAlbumModel *)model error:(NSError *)error;

- (void)didCreateShareSucceed:(AbstractAlbumModel *)model shareToken:(NSString *)shareToken;

- (void)didCreateShareFail:(AbstractAlbumModel *)model error:(NSError *)error;

- (void)albumDeletionSuccessWith:(AbstractAlbumModel *)model;

- (void)albumDeletionFailWith:(NSError *)error;


@end




