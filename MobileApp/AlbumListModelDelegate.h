//
//  EventAlbumListModelDelegate.h
//  MobileApp
//
//  Created by Jon Campbell on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractModelDelegate.h"

@class AlbumListModel;

@protocol AlbumListModelDelegate <AbstractModelDelegate>

@optional
- (void)didJoinAllSucceed:(AlbumListModel *)model;

- (void)didJoinAllFail:(AlbumListModel *)model error:(NSError *)error;

@end
