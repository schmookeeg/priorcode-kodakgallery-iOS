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

@interface AlbumListDataSource : TTListDataSource <AlbumListModelDelegate>
{
    BOOL _hideEmpty;
    BOOL _isLoaded;
	NSNumber *_filterAlbumType;
	NSMutableArray *_delegates;
    NSArray *_visibleAlbums;
}

- (id)initWithFilterAlbumType:(NSNumber *)filterAlbumType;

- (void)populateDataSourceFromModel;

- (NSNumber *)filterAlbumType;

- (void)setFilterAlbumType:(NSNumber *)filterAlbumType;

- (void)clearFilterAlbumType;

- (NSDate *)loadedTime;


@property ( nonatomic, readonly ) AlbumListModel *albumList;
@property(nonatomic, assign) BOOL hideEmpty;
@property(nonatomic, retain) NSArray *visibleAlbums;


@end
