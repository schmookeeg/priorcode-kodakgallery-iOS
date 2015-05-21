//
//  SPMProductListDataSource.h
//  MobileApp
//
//  Created by Darron Schall on 2/27/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "SPMProductList.h"

@interface SPMProductListDataSource : TTListDataSource <AbstractModelDelegate>
{
	BOOL _isLoaded;
	NSMutableArray *_delegates;
}

@property ( nonatomic, readonly ) SPMProductList *productList;
@property ( nonatomic, retain ) NSNumber *albumId;
@property ( nonatomic, retain ) NSNumber *photoId;

- (id)initWithAlbumId:(NSNumber *)albumId photoId:(NSNumber *)photoId;

- (void)changePhotoToPhotoId:(NSNumber *)photoId inAlbumId:(NSNumber *)albumId;

@end
