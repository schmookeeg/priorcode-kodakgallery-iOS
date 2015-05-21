//
//  UserModel+Permissions.h
//  MobileApp
//
//  Created by Darron Schall on 11/9/11.
//  Copyright (c) 2011 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import "AbstractAlbumModel.h"
#import "PhotoModel.h"

@interface UserModel (Permissions)

- (BOOL)canDownloadPhoto:(PhotoModel *)photo fromAlbum:(AbstractAlbumModel *)album;

- (BOOL)canEditAlbum:(AbstractAlbumModel *)album;

- (BOOL)canDeletePhoto:(PhotoModel *)photo inAlbum:(AbstractAlbumModel *)album;

- (BOOL)canRotatePhoto:(PhotoModel *)photo inAlbum:(AbstractAlbumModel *)album;

@end
