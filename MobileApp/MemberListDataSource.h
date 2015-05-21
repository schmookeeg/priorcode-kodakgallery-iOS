//
//  MemberListDataSource.h
//  MobileApp
//
//  Created by Jon Campbell on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "AbstractAlbumModel.h"

@interface MemberListDataSource : TTListDataSource
{
	BOOL _isLoaded;
	AbstractAlbumModel *_eventAlbum;
	NSMutableArray *_delegates;
	int _anonymousUsers;
}

- (id)initWithEventAlbum:(AbstractAlbumModel *)eventAlbum;

- (void)populateDataSourceFromModel;

@property ( nonatomic, assign ) AbstractAlbumModel *eventAlbum;

@end
