//
//  PhotoCommentsDataSource.h
//  MobileApp
//
//  Created by mikeb on 6/22/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "PhotoCommentsListModel.h"
#import "PhotoCommentsListModelDelegate.h"

@interface PhotoCommentsDataSource : TTListDataSource <PhotoCommentsListModelDelegate>
{
	BOOL _isLoaded;
	PhotoCommentsListModel *_photoCommentsList;
	NSMutableArray *_delegates;
	NSString *_photoId;
}

@property ( nonatomic, retain ) PhotoCommentsListModel *photoCommentsList;

- (id)initWithPhotoId:(NSString *)photoId;

- (NSDate *)loadedTime;

@end
