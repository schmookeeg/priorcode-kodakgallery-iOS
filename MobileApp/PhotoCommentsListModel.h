//
//  PhotoCommentsListModel.h
//  MobileApp
//
//  Created by Peter Traeg on 6/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Restkit/RestKit.h>
#import "AbstractModel.h"
#import "PhotoCommentsListModelDelegate.h"

@interface PhotoCommentsListModel : AbstractModel <RKRequestDelegate>
{
	NSString *_photoId;
	NSMutableArray *_comments;
	id <PhotoCommentsListModelDelegate> _delegateOverride;
}

@property ( nonatomic, assign ) id <PhotoCommentsListModelDelegate> delegate;
@property ( retain, nonatomic ) NSString *photoId;
@property ( retain, nonatomic ) NSMutableArray *comments;

- (void)fetchWithPhotoId:(NSString *)photoId;

- (void)addComment:(NSString *)commentText;

@end
