//
//  EventAlbumListModel.h
//  MobileApp
//
//  Created by Jon Campbell on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "AbstractModel.h"
#import "Three20/Three20.h"
#import "AlbumModelDelegate.h"
#import "AlbumListModelDelegate.h"
#import "AbstractAlbumModel.h"

@interface AlbumListModel : AbstractModel <AlbumModelDelegate>
{
	NSArray *_albums;
	int _currentJoinIndex;
	id <AlbumListModelDelegate> _delegateOverride;
}

- (void)joinAllAlbums;

- (void)joinAlbum;

- (AbstractAlbumModel *)albumFromAlbumId:(NSNumber *)albumId;

+ (AlbumListModel *)albumList;

@property ( nonatomic, assign ) id <AlbumListModelDelegate> delegate;

@property ( nonatomic, retain ) NSArray *albums;

@end
