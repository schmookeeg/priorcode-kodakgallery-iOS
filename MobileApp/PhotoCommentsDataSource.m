//
//  PhotoCommentsDataSource.m
//  MobileApp
//
//  Created by Dev on 6/22/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "PhotoCommentsDataSource.h"
#import "PhotoCommentModel.h"
#import "CommentTableCellView.h"
#import "AlbumAnnotationsModel.h"

@implementation PhotoCommentsDataSource
@synthesize photoCommentsList = _photoCommentsList;

- (id)initWithPhotoId:(NSString *)photoId
{
	self = [super init];

	_isLoaded = NO;
	_photoId = photoId;
	self.photoCommentsList = [[[PhotoCommentsListModel alloc] init] autorelease];
	[self.photoCommentsList setDelegate:self];
	[self.photoCommentsList fetchWithPhotoId:photoId];
	return self;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	[super load:cachePolicy more:more];
	_isLoaded = NO;
	[self.photoCommentsList setDelegate:self];
	[self.photoCommentsList fetchWithPhotoId:_photoId];
	[self.delegates makeObjectsPerformSelector:@selector(modelDidStartLoad:) withObject:self];
}


- (void)populateDataSourceFromModel
{
	_isLoaded = YES;

	NSMutableArray *tItems = [NSMutableArray array];

	// First add the standard comments that we just retrieved 
	for ( PhotoCommentModel *photoComment in [_photoCommentsList comments] )
	{

		TTTableMessageItem *item = [TTTableMessageItem itemWithTitle:photoComment.author
															 caption:@"COMMENT"
																text:photoComment.text
														   timestamp:[photoComment lastUpdated]
															imageURL:[photoComment authorAvatarUrl]
																 URL:nil];

		[tItems insertObject:item atIndex:[tItems count]];
	}

	// Now add the 'likes' for this photo
	NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber *photoId = [f numberFromString:_photoId];
	[f release];

	NSArray *photoLikes = [[AlbumAnnotationsModel annotationsForPhotoId:photoId createIfNil:NO] annotations];
	for ( PictureAnnotationModel *photoLike in photoLikes )
	{
		TTTableMessageItem *item = [TTTableMessageItem itemWithTitle:photoLike.annotatorName
															 caption:@"LIKE"
																text:@"Liked this photo."
														   timestamp:[photoLike timeStamp]
															imageURL:[photoLike annotatorAvatarUrl]
																 URL:nil];
		[tItems insertObject:item atIndex:[tItems count]];
	}

	// Sort the TTTableMessageItems (containing comments and likes) by timestamp in descending order
	[tItems sortUsingComparator:^( id obj1, id obj2 )
								{
									if ( [obj1 isKindOfClass:[TTTableMessageItem class]] && [obj2 isKindOfClass:[TTTableMessageItem class]] )
									{
										TTTableMessageItem *t1 = (TTTableMessageItem *) obj1;
										TTTableMessageItem *t2 = (TTTableMessageItem *) obj2;

										NSComparisonResult compareResult = [[t1 timestamp] compare:[t2 timestamp]];

										// Flip the compareResult to create descending order
										if ( NSOrderedAscending == compareResult )
										{
											return NSOrderedDescending;
										}
										else if ( NSOrderedDescending == compareResult )
										{
											return NSOrderedAscending;
										}

									}
									return (NSComparisonResult) NSOrderedSame;
								}];

	[self setItems:tItems];

}

- (BOOL)isLoading
{
	return !_isLoaded;
}

- (BOOL)isLoaded
{
	return _isLoaded;
}

- (void)didModelLoad:(AbstractModel *)model;
{
	[self populateDataSourceFromModel];
	[_delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];
}

- (NSMutableArray *)delegates
{
	if ( nil == _delegates )
	{
		_delegates = TTCreateNonRetainingArray();
	}
	return _delegates;
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object
{
	// This forces TTableView to use our custom CommentTableCellView rather than 
	// loading different views based on the type of TableItem being passed in.
	return [CommentTableCellView class];
}

- (NSDate *)loadedTime;
{
	return _photoCommentsList.populateTime;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_delegates)
	_photoCommentsList.delegate = nil;
	[_photoCommentsList release];
	_photoCommentsList = nil;
	[super dealloc];
}


@end
