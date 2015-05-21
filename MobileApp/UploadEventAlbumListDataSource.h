//
//  EventAlbumListTTListDataSource.h
//  MobileApp
//
//  Created by Jon Campbell on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "AlbumListModel.h"
#import "AlbumListModelDelegate.h"

@interface UploadEventAlbumListDataSource : TTListDataSource <AlbumListModelDelegate>
{
	BOOL _isLoaded;
	AlbumListModel *_albumList;
	NSMutableArray *_delegates;
}

- (id)initWithEventAlbumList:(AlbumListModel *)albumList;

- (void)populateDataSourceFromModel;

@property ( nonatomic, retain ) AlbumListModel *albumList;

@end
