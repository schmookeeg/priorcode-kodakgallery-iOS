//
//  Created by darron on 3/22/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SelectSinglePhotoViewController.h"
#import "AlbumListModel.h"
#import "UserModel+Permissions.h"

@implementation SelectSinglePhotoViewController

@synthesize selectPhotosDelegate = _selectPhotosDelegate;

#pragma mark init / dealloc

- (id)init
{
	self = [super init];
	if ( self )
	{

	}
	return self;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_rotateLeftBarButton)

	[super dealloc];
}

#pragma mark View LifeCycle

- (void)loadView
{
	[super loadView];

	// Overwrite the toolbar with only the items that we're interested in
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixedSpace.width = 20;

	_rotateLeftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kAssetRotateLeftIcon]
															style:UIBarButtonItemStylePlain
														   target:self
														   action:@selector(rotateImageAction:)];
	[_rotateLeftBarButton setTag:kRotateLeftButtonTag];

	_toolbar.items = [NSArray arrayWithObjects:flexibleSpace, _rotateLeftBarButton, fixedSpace, _rotateRightBarButton, flexibleSpace, nil];

	[flexibleSpace release];
	[fixedSpace release];

	// Release objects our parent class made to free up memory
	self.shareButton = nil;
	self.likeButton = nil;
	self.commentButton = nil;

	self.statusBarStyle = UIStatusBarStyleBlackOpaque;
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	TT_RELEASE_SAFELY(_rotateLeftBarButton)
}

/**
 * Override to update the title and place a Use Photo button in the top right.
 */
- (void)updateChrome
{
	// Create the Use Photo button in the top right
	UIBarButtonItem *usePhotoButton = [[UIBarButtonItem alloc] initWithTitle:@"Use Photo" style:UIBarButtonItemStyleDone target:self action:@selector(usePhotoAction:)];
	self.navigationItem.rightBarButtonItem = usePhotoButton;
	[usePhotoButton release];
}

- (void)updatePhotoView
{
	[super updatePhotoView];

	self.navigationItem.backBarButtonItem.title = @"Select photo";
}

- (void)modelDidFinishLoad:(id <TTModel>)model
{
	[super modelDidFinishLoad:model];
}

- (void)pauseAction
{
	// Empty override.  Nothing to do, because slide show will never be played.
}

- (void)showBars:(BOOL)show animated:(BOOL)animated
{
	// Empty override, don't want to consume the full screen
}

- (void)consumeFullScreen:(BOOL)fullScreen
{
	// Empty override, don't want to consume the full screen
}

- (void)scrollView:(TTScrollView *)scrollView tapped:(UITouch *)touch
{
	// Empty override, don't want to consume the full screen
}

- (void)showTipsAlways:(BOOL)alwaysShow
{
    // Empty override, don't show the comments tip in the Select screen because
    // there is no comments button to point to.
}

/**
 * Override to account for the rotate left toolbar button that we added.
 */
- (void)updateRotationButtonEnabled
{
	[super updateRotationButtonEnabled];

	// Assign the correct UIImage for the rotate button based on the enabled state
	AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
	BOOL rotateEnabled = [[UserModel userModel] canRotatePhoto:(PhotoModel *) self.centerPhoto inAlbum:album];
	if ( rotateEnabled )
	{
		_rotateLeftBarButton.image = [UIImage imageNamed:kAssetRotateLeftIcon];

	}
	else
	{
		_rotateLeftBarButton.image = [UIImage imageNamed:kAssetRotateLeftDisabledIcon];
	}
}

#pragma mark Actions

- (void)usePhotoAction:(id)sender
{
	// Inform the delegate of the selected photos
	if ( [_selectPhotosDelegate respondsToSelector:( @selector(selectPhotosDidSelectPhotos:inAlbum:) )] )
	{
		NSArray *photos = [NSArray arrayWithObject:self.centerPhoto];
		AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];

		[_selectPhotosDelegate selectPhotosDidSelectPhotos:photos inAlbum:album];
        
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Shop:Use Photo"];
	}
}

@end