//
//  PhotoCommentsListTableViewController.m
//  MobileApp
//
//  Created by P. Traeg on 6/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "PhotoCommentsListTableViewController.h"
#import "PhotoCommentsDataSource.h"
#import "AlbumAnnotationsModel.h"
#import "UIImage+LikeImage.h"

@implementation PhotoCommentsListTableViewController
@synthesize photoId = _photoId, photoModel, albumAnnotationsModel = _albumAnnotationsModel, photoCommentsModel = _photoCommentsModel;

- (void)updateLikeButton
{
	_likeButton.image = [UIImage likeImageForPhoto:self.photoId];
	_likeButton.enabled = YES;
}


- (id)initWithPhotoId:(NSString *)photoId
{

	if ( ( self = [super init] ) )
	{
		self.hidesBottomBarWhenPushed = YES;
		self.title = @"Comments";
		self.variableHeightRows = YES;

		self.photoId = photoId;

		headerView = [[self headerView] retain];
		[[self tableView] setTableHeaderView:headerView];
		_likeButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage likeImageForPhoto:self.photoId]
														style:UIBarButtonItemStylePlain target:self action:@selector(likePhotoClicked)] autorelease];
	}

	return self;
}

- (id)initWithPhotoIdPost:(NSString *)photoId
{
	self.hidesBottomBarWhenPushed = YES;
	_enterCommentPostMode = YES;
	return [self initWithPhotoId:photoId];
}

#pragma mark PhotoCommentsListModelDelegate

- (void)didAddCommentSucceed:(PhotoCommentsListModel *)model
{
	NSLog( @"Comment added.  Reloading comment list." );
	// Load the comments for the photoId again to show the one we just added
	[[(PhotoCommentsDataSource *) self.dataSource photoCommentsList] fetchWithPhotoId:self.photoId];
}

- (void)didAddCommentFail:(PhotoCommentsListModel *)model  error:(NSError *)error
{
	NSLog( @"AddComment failed!" );
}

#pragma mark AlbumPicturesAnnotationsModelDelegate

- (void)didLikeSucceed:(AlbumPicturesAnnotationsModel *)model;
{
	model.delegate = nil;
	NSLog( @"Like added.  Redisplaying view." );
	[self updateLikeButton];
	// Load the comments for the photoId again to show the one we just added
	[[(PhotoCommentsDataSource *) self.dataSource photoCommentsList] fetchWithPhotoId:self.photoId];
}

- (void)didLikeFail:(AlbumPicturesAnnotationsModel *)model  error:(NSError *)error;
{
	model.delegate = nil;
	NSLog( @"AddLike failed!" );
}


- (void)didUnLikeSucceed:(AlbumPicturesAnnotationsModel *)model;
{
	model.delegate = nil;
	NSLog( @"Unliked photo.  Redisplaying view." );
	[self updateLikeButton];
	// Load the comments for the photoId again to show the one we just added
	[[(PhotoCommentsDataSource *) self.dataSource photoCommentsList] fetchWithPhotoId:self.photoId];

}

- (void)didUnLikeFail:(AlbumPicturesAnnotationsModel *)model  error:(NSError *)error;
{
	model.delegate = nil;
	NSLog( @"Unlike failed!" );
}

#pragma mark TTPostControllerDelegate

- (void)postController:(TTPostController *)commentPostController
		   didPostText:(NSString *)text
			withResult:(id)result;
{
	NSLog( @"Comment text posted: %@", text );
	if ( !self.photoCommentsModel )
	{
		self.photoCommentsModel = [[[PhotoCommentsListModel alloc] init] autorelease];
		self.photoCommentsModel.photoId = self.photoId;
		self.photoCommentsModel.delegate = self;
	}
	[self.photoCommentsModel addComment:text];
	NSNumber *commentCount = [NSNumber numberWithInt:[[self.photoModel numComments] intValue] + 1];
	self.photoModel.numComments = commentCount;

	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Add Comment"];
	TT_RELEASE_SAFELY(postController);
}

- (void)postControllerDidCancel:(TTPostController *)commentPostController;
{
	NSLog( @"Post cancelled" );
	TT_RELEASE_SAFELY(postController);
}

- (void)showCommentPostForm
{
	postController = [[TTPostController alloc] init];

	postController.delegate = self;
	postController.title = @"Post a comment";

	postController.navigationItem.rightBarButtonItem.enabled = false;
	postController.textView.delegate = self;
	postController.originView = headerView;

	[postController showInView:self.view animated:YES];

}

- (void)textViewDidChange:(UITextView *)textView
{
	postController.navigationItem.rightBarButtonItem.enabled = ( [[textView text] length] > 0 );
}

- (void)likePhotoClicked
{
	_likeButton.enabled = NO;

	NSNumber *photoIdAsNumber = [NSNumber numberWithDouble:[self.photoId doubleValue]];

	self.albumAnnotationsModel = [AlbumAnnotationsModel annotationsForPhotoId:photoIdAsNumber createIfNil:YES];
	self.albumAnnotationsModel.delegate = self;
	[self.albumAnnotationsModel toggleLike];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	NSLog( @"You tapped the comment entry box" );
	[self showCommentPostForm];
	return NO;
}

- (UIView *)headerView
{
	if ( headerView )
	{
		return headerView;
	}

	float w = [[UIScreen mainScreen] bounds].size.width;

	if ( [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight )
	{
		w = [[UIScreen mainScreen] bounds].size.height;
	}

	headerTextField = [[UITextField alloc] initWithFrame:CGRectMake( 8.0, 8.0, w - 16.0, 30.0 )];

	[headerTextField setPlaceholder:@"Write a comment"];
	[headerTextField setBorderStyle:UITextBorderStyleRoundedRect];
	[headerTextField setDelegate:self];

	CGRect headerViewFrame = CGRectMake( 0, 0, w, 48 );
	headerView = [[UIView alloc] initWithFrame:headerViewFrame];

	[headerView addSubview:headerTextField];
	[headerView setBackgroundColor:[UIColor darkGrayColor]];

	return headerView;
}

- (void)done
{
	[UIView beginAnimations:@"animation" context:nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
	[UIView setAnimationDuration:.7];
	[UIView commitAnimations];
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)dealloc
{
	self.photoCommentsModel.delegate = nil;
	self.photoCommentsModel = nil;

	self.albumAnnotationsModel.delegate = nil;
	self.albumAnnotationsModel = nil;

	self.photoId = nil;
	self.photoModel = nil;

	[postController release];
	[headerView release];
	[headerTextField release];

	[super dealloc];

}

- (void)viewWillDisappear:(BOOL)animated
{
	NSLog( @"photoComment viewWillDisappear" );

	[super viewWillDisappear:animated];

	self.dataSource = nil;

	self.photoCommentsModel.delegate = nil;
	self.photoCommentsModel = nil;

	self.albumAnnotationsModel.delegate = nil;
	self.albumAnnotationsModel = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationItem.leftBarButtonItem = _likeButton;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done)] autorelease];

	self.dataSource = [[[PhotoCommentsDataSource alloc] initWithPhotoId:self.photoId] autorelease];

	[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Album List:Album:Photo:Comments"];

	if ( _enterCommentPostMode )
	{
		_enterCommentPostMode = NO;
		[self showCommentPostForm];
	}

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
										 duration:(NSTimeInterval)duration
{
	[super willAnimateRotationToInterfaceOrientation:fromInterfaceOrientation duration:duration];
	if ( postController != nil )
	{
		// Comment post form view is being displayed over the top of this viewcontroller - tell it to rotate as well
		[postController willAnimateRotationToInterfaceOrientation:fromInterfaceOrientation duration:duration];
	}
}

// Add DragRefresh delegate to provide pull-to-refresh support
- (id <TTTableViewDelegate>)createDelegate
{
	TTTableViewDragRefreshDelegate *delegate = [[TTTableViewDragRefreshDelegate alloc] initWithController:self];

	return [delegate autorelease];
}

- (void)showEmpty:(BOOL)show
{
	// In the case of an empty view TTTableViewController never calls createDelegate so we won't get Pull-To-Refresh
	// capability on empty comment lists.  This override makes sure createDelegate is called anyway.
	[super showEmpty:show];
	if ( !self.tableView.delegate )
	{
		id <UITableViewDelegate> tableDelegate = [[self createDelegate] retain];

		// You need to set it to nil before changing it or it won't have any effect
		self.tableView.delegate = nil;
		self.tableView.delegate = tableDelegate;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{

	float w = [[UIScreen mainScreen] bounds].size.width;

	if ( toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight )
	{
		w = [[UIScreen mainScreen] bounds].size.height;
	}


	// resize header text field
	[headerTextField setFrame:CGRectMake( 8.0, 8.0, w - 16.0, 30.0 )];

	return YES;
}

@end
