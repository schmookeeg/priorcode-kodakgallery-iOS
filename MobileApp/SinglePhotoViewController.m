//
//  SinglePhotoViewController.m
//  MobileApp
//
//  Created by Dev on 6/2/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "SinglePhotoViewController.h"
#import "Three20UI/UIToolbarAdditions.h"
#import "PhotoCommentsListTableViewController.h"
#import "SettingsModel.h"
#import <objc/message.h>
#import "MobileAppAppDelegate.h"
#import "NotificationsViewController.h"
#import "AlbumListModel.h"
#import "UserModel+Permissions.h"
#import "UIImage+LikeImage.h"

const CGFloat COMMENT_BAR_HEIGHT = 35;

static const NSTimeInterval kPhotoLoadLongDelay = 0.5;

@implementation SinglePhotoViewController

@synthesize photoSet = _photoSet;
@synthesize albumId = _albumId;
@synthesize autoPlay = _autoPlay;

@synthesize likeButton = _likeButton;
@synthesize commentButton = _commentButton;
@synthesize shareButton = _shareButton;
@synthesize photoOptionActionSheetController = _photoOptionActionSheetController;

@synthesize pictureAnnotationsModel = _pictureAnnotationsModel;

- (id)initWithAlbumId:(NSNumber *)albumId
{
	self = [super init];
	
	if ( self )
	{
		[self setAlbumId:albumId];
		self.photoSource = [[[AlbumPhotoSource alloc] initWithAlbumId:[self albumId]] autorelease];

		_slideShowActive = NO;
		barsAreHidden = NO;

		_rotateRightBarButton = nil;
		_deleteBarButton = nil;
	}

	return self;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_hud)
	TT_RELEASE_SAFELY(_photoSet)
	TT_RELEASE_SAFELY(_photoSource)

	// Use the setter here instead of just releasing to make sure KVO gets cleaned up
	self.pictureAnnotationsModel = nil;

	TT_RELEASE_SAFELY(_innerView)
	TT_RELEASE_SAFELY(_scrollView)

	TT_RELEASE_SAFELY(_likeButton)
	TT_RELEASE_SAFELY(_commentButton)

	TT_RELEASE_SAFELY(_nextButton)
	TT_RELEASE_SAFELY(_previousButton)
	TT_RELEASE_SAFELY(_rotateRightBarButton)
	TT_RELEASE_SAFELY(_deleteBarButton)
	TT_RELEASE_SAFELY(_toolbar)

	TT_RELEASE_SAFELY(_slideshowTimer)
	TT_RELEASE_SAFELY(_tipView)

	TT_RELEASE_SAFELY(_albumId)
	TT_RELEASE_SAFELY(_shareButton)
	TT_RELEASE_SAFELY(_photoOptionActionSheetController)

	[super dealloc];
}

- (PhotoModel *)currentPhoto
{
	return (PhotoModel *) [self.photoSource photoAtIndex:self.centerPhotoIndex];
}

- (void)setPictureAnnotationsModel:(AlbumPicturesAnnotationsModel *)pictureAnnotationsModel
{
	[_pictureAnnotationsModel removeObserver:self forKeyPath:@"annotations"];

	[pictureAnnotationsModel retain];
	[_pictureAnnotationsModel release];
	_pictureAnnotationsModel = pictureAnnotationsModel;

	[_pictureAnnotationsModel addObserver:self forKeyPath:@"annotations" options:0 context:NULL];
}

- (void)showTipsAlways:(BOOL)alwaysShow
{
	if ( _slideShowActive )
	{
		return;
	}

	if ( alwaysShow || ![[SettingsModel settings] tipDisplayedCommentsButton] )
	{
		// Haven't displayed the upload tip
		if ( _tipView != nil && _tipView.targetObject != nil )
		{
			[_tipView dismissAnimated:YES];
			[_tipView release];
		}
		_tipView = [[CMPopTipView alloc] initWithMessage:@"Tap here to read and write\ncomments about this photo."];
		_tipView.backgroundColor = POPTIP_BACKGROUND_COLOR;
		_tipView.textColor = POPTIP_TEXT_COLOR;
		_tipView.delegate = nil;
		_tipView.animation = CMPopTipAnimationPop;
		[_tipView presentPointingAtView:self.commentButton inView:self.view animated:YES];
	}
}

- (BOOL)isNotificationsScreenInNavigationHistory
{
	// check to see if coming from notifications screen
	NSArray *navViewControllers = self.navigationController.viewControllers;
	// subtract 3 from length
	return [[navViewControllers objectAtIndex:navViewControllers.count - 3] class] == [NotificationsViewController class];
}

- (void)returnToNotifications
{
	[[self navigationController] popToRootViewControllerAnimated:YES];
}

- (void)returnToAlbumAnimated:(BOOL)animated
{
	[[self navigationController] popViewControllerAnimated:animated];
}

- (void)returnToAlbum
{
	[self returnToAlbumAnimated:NO];
}

- (void)consumeFullScreen:(BOOL)fullScreen
{
    if ( fullScreen )
    {
        objc_msgSend( self, @selector(showBars:animated:), NO, YES );
        self.wantsFullScreenLayout = YES;
		barsAreHidden = YES;
    }
    else
    {
        objc_msgSend( self, @selector(showBars:animated:), YES, NO );
        // This line below is the culprit for the white statusbar problem described
        // in STABTWO-2014
        //self.wantsFullScreenLayout = NO;
        barsAreHidden = NO;
    }    
}

/*
Override TTPhotoViewController implementation
 */
-(void)showBarsAnimationDidStop
{
    // KLUDGE: Hide and then re-show the navigation bar to prevent the overlapping
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;

	barsAreHidden = NO;
}

/*
Override TTPhotoViewController implementation
 */
- (void)hideBarsAnimationDidStop
{
	self.navigationController.navigationBarHidden = YES;
	barsAreHidden = YES;
}

- (void)didApplicationBecomeInactiveNotification:(NSNotification *)notification
{
	if ( [[[TTNavigator navigator] visibleViewController] isEqual:self] )
	{
		[self consumeFullScreen:NO];
	}
}

- (void)modelDidFinishLoad:(id <TTModel>)model
{
	NSLog( @"SinglePhotoViewController - model loaded" );

	BOOL albumContainsPhotos = [[(AlbumPhotoSource *) self.photoSource photos] count] > 0;
	if ( !albumContainsPhotos )
	{
		// Nothing to display, so we shouldn't be in this view.  Pop back out to the album.
		// NOTE: We only get here if we delete the only photo in an album in the single photo view.

		if ( isDeleting )
		{
			isDeleting = NO;
			[_hud hide:YES];
		}

		if ( [self isNotificationsScreenInNavigationHistory] )
		{
			[self returnToNotifications];
		}
		else
		{
			[self returnToAlbumAnimated:YES];
		}
	}
	else
	{
		[super modelDidFinishLoad:model];

		if ( isDeleting )
		{
			isDeleting = NO;

			[self updateDeleteButtonEnabledAndHideDeletingMessage];
		}
		else if ( isRotating )
		{
			// If the model loaded and our rotating flag is set, make sure that we've actually recevied a response
            // from the rotate call before we dismiss the rotate dialog.  There's a chance that the modelDidFinishLoad
            // was triggered by something *other* than our data source refresh (after rotate success), especially on
            // slow/throttled connections.
            if ( receivedPhotoRotateResponse )
            {
                isRotating = NO;
                
                [self updateRotationButtonEnabledAndHideRotatingMessage];
            }
            
		}
        else
        {
            // Not deleting or rotating, make sure the view is currently correct.
            // Placing this here instead (to make sure we're not rotating or deleting)
            // instead of performing this all of the time makes sure that after a rotate
            // the like and comment values are correct (since the annotations might not
            // be loaded, which means when you like a photo it won't appear as liked
            // until after the annotations actually re-load).
            self.navigationItem.title = [(id <TTPhotoSource>) model title];
            // This refresh call was initially added when photo delete feature went in.
            [self refresh];
        }
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Override TTPhotoViewController so we can preload large images instead of low-res thumbnails
//
- (void)loadImages
{
	TTPhotoView *centerPhotoView = (TTPhotoView *) _scrollView.centerPage;
	for ( TTPhotoView *photoView in _scrollView.visiblePages.objectEnumerator )
	{
		if ( photoView == centerPhotoView )
		{
			// Load a thumbnail from cache if possible for the center view just in case we don't have the
			// large photo in cache yet.
			[photoView loadPreview:NO];
		}
		[photoView loadImage];
	}
}

- (void)startSlideshowTimerWithInterval:(NSTimeInterval)interval
{
	[_slideshowTimer invalidate];
	[_slideshowTimer release];
	_slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:interval
													   target:self
													 selector:@selector(slideshowTimer)
													 userInfo:nil repeats:NO];
	[_slideshowTimer retain];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Override TTPhotoViewController so we can check that the next image has loaded before advancing to it
//
- (void)slideshowTimer
{

	NSInteger nextIndex;

	if ( _centerPhotoIndex == _photoSource.numberOfPhotos - 1 )
	{
		nextIndex = 0;
	}
	else
	{
		nextIndex = _centerPhotoIndex + 1;
	}

	id <TTPhoto> nextPhoto = [_photoSource photoAtIndex:nextIndex];
	NSString *nextPhotoURL = [nextPhoto URLForVersion:TTPhotoVersionLarge];

	if ( [[TTURLCache sharedCache] hasImageForURL:nextPhotoURL fromDisk:YES] )
	{
		_scrollView.centerPageIndex = nextIndex;

		NSTimeInterval interval = (double) slideshowLength;
		[self startSlideshowTimerWithInterval:interval];

	}
	else
	{
		// Wait 1 sec and see if the image has come into the cache
		NSTimeInterval interval = (double) 1;
		[self startSlideshowTimerWithInterval:interval];
	}

}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Override TTPhotoViewController so we can set our own slideShowInterval
//
- (void)playAction
{
	if ( !_slideshowTimer )
	{

		[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Play Slideshow" eventName:@"event11"];

		UIBarButtonItem *pauseButton =
				[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
															   target:self
															   action:@selector(pauseAction)]
						autorelease];
		pauseButton.tag = 1;

		[_toolbar replaceItemWithTag:1 withItem:pauseButton];

		[self consumeFullScreen:YES];
        
		NSTimeInterval interval = (double) slideshowLength;
		[self startSlideshowTimerWithInterval:interval];

		_slideShowActive = YES;
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updatePhotoView
{
	_scrollView.centerPageIndex = _centerPhotoIndex;
	[self loadImages];

	if ( [self respondsToSelector:@selector(updateChrome)] )
	{
		//[self updateChrome];
		objc_msgSend( self, @selector(updateChrome) );
	}

	self.navigationItem.backBarButtonItem.title = [NSString stringWithFormat:@"%d of %d", _centerPhotoIndex + 1, [_photoSource numberOfPhotos]];

	// Displaying a new photo, so we need to set the new annotations model for the photo.  Note that we always create a model if it
	// doesn't exist because we need a valid reference for our key-value observing to work.
	self.pictureAnnotationsModel = [AlbumAnnotationsModel annotationsForPhotoId:self.currentPhoto.photoId createIfNil:YES];

    NSLog( @"Updating photo view to id %@", self.currentPhoto.photoId );
    
	[self updateToolbarButtons];
}

- (void)pauseAction
{
	if ( [super respondsToSelector:@selector(pauseAction)] )
	{
		//[super pauseAction];
		struct objc_super s = { self, [self superclass] };
		objc_msgSendSuper( &s, @selector(pauseAction) );
	}

	if ( _slideShowActive )
	{
        _slideShowActive = NO;
        [self showTipsAlways:NO];
	}
}


#pragma mark - Confirm Photo Delete

- (void)deletePhotoAction:(id)sender
{
	AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
	if ( [[UserModel userModel] canDeletePhoto:self.currentPhoto inAlbum:album] )
	{
		UIActionSheet *confirmDeleteActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
																		 cancelButtonTitle:@"Cancel"
																	destructiveButtonTitle:@"Delete Photo"
																		 otherButtonTitles:nil];
			[confirmDeleteActionSheet showInView:self.view];
			[confirmDeleteActionSheet release];
	}
	else
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Delete Photo"
															message:@"Only the owner of this photo can delete the photo."
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];

		[alertView show];
		[alertView autorelease];

	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( buttonIndex == [actionSheet destructiveButtonIndex] )
	{
		[self deletePhoto];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // FIXME: Refector this into a helper method/util/category because it's eerily similar
    // to the fix put in place for STABTWO-2026, and similar to other code in the project.
    // https://jc.ofoto.com/jira/browse/STABTWO-2029
    if (_hud )
    {
        _hud.bounds = _hud.superview.bounds;
		[_hud setNeedsDisplay];
    }
}

#pragma mark - Delete

- (void)deletePhoto
{
	self.hud.labelText = @"Deleting photo...";
	[self.hud show:YES];

    // FIXME This should be refactored into a category, this code exists in at least 3 different places
    // https://jc.ofoto.com/jira/browse/STABTWO-2026 - There's an issue with the MBProgressHUD subproject
	// that causes it to have the wrong bounds set in certain situations (where the device is rotated but
	// the screen is not yet updated, such as when an actionsheet is present).
	// Force the hud bounds to take on that of the superview so make sure that the user interactions
	// with the screen are disabled while the hud is up.
	dispatch_async( dispatch_get_main_queue(), ^{
		// The below lines are the same as what is in the deviceOrientationDidChange message, but
		// that's a private message we can't send so we have to do this manually.
		//[self.hud deviceOrientationDidChange];
		self.hud.bounds = self.hud.superview.bounds;
		[self.hud setNeedsDisplay];
	});
    
    isDeleting = YES;
    
	[self.currentPhoto deletePhotoFromAlbum:self.albumId];
	self.currentPhoto.delegate = self;
}

- (void)updateDeleteButtonEnabledAndHideDeletingMessage
{
	[self updateDeleteButtonEnabled];
	[_hud hide:YES];
}

#pragma mark PhotoModelDelegate delete methods

- (void)photoDeletionDidSucceedWithModel:(PhotoModel *)model
{
	self.currentPhoto.delegate = nil;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAnyChange"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[( (AlbumPhotoSource *) self.photoSource ) refresh];

	// Controler flow is transferred to refreshing the album information, which
	// will invoke modelDidFinishLoad:
}


- (void)photoDeletionDidFailWithError:(NSError *)error
{
	self.currentPhoto.delegate = nil;
    
    isDeleting = NO;
	[[[[UIAlertView alloc] initWithTitle:@"Deletion Failed"
								 message:@"Photo deletion failed. Please try again later."
								delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];

	[self updateDeleteButtonEnabledAndHideDeletingMessage];
}

#pragma mark - Rotate

- (void)rotateImageAction:(UIBarButtonItem *)sender
{
	AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
	if ( [[UserModel userModel] canRotatePhoto:self.currentPhoto inAlbum:album] )
	{
		receivedPhotoRotateResponse = NO;

		isRotating = YES;

		self.hud.labelText = @"Rotating photo...";
		[self.hud show:YES];

		self.currentPhoto.delegate = self;

		if ( sender.tag == kRotateRightButtonTag )
		{
//			NSLog( @"Rotating photo id: %@", self.currentPhoto.photoId );

			[self.currentPhoto rotateRightInAlbum:self.albumId];
		}
		else if ( sender.tag == kRotateLeftButtonTag )
		{
			[self.currentPhoto rotateLeftInAlbum:self.albumId];
		}
	}
	else
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Rotate Photo"
															message:@"Only the owner of this photo can rotate the photo."
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
		[alertView show];
		[alertView autorelease];
	}
}


- (void)updateRotationButtonEnabledAndHideRotatingMessage
{
	[self updateRotationButtonEnabled];
	[_hud hide:YES];
}

#pragma mark PhotoModelDelegate rotate methods

- (void)photoRotationDidSucceedWithModel:(PhotoModel *)model
{
	self.currentPhoto.delegate = nil;
    receivedPhotoRotateResponse = YES;
    
    [((AlbumPhotoSource *) self.photoSource ) refresh];
    
    // Controler flow is transferred to refreshing the album information, which
	// will invoke modelDidFinishLoad:
}

- (void)photoRotationDidFailWithError:(NSError *)error
{
	self.currentPhoto.delegate = nil;
    
    isRotating = NO;
    receivedPhotoRotateResponse = YES;

	[self updateRotationButtonEnabledAndHideRotatingMessage];

	[[[[UIAlertView alloc] initWithTitle:@"Rotation Failed"
								 message:@"Photo rotation failed. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
}

#pragma mark -

- (void)photoOptionAction:(id)sender
{
	AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
	BOOL allowDownload = [[UserModel userModel] canDownloadPhoto:self.currentPhoto fromAlbum:album];

	self.photoOptionActionSheetController = [[[PhotoOptionActionSheetController alloc] initWithDelegate:self album:album photo:self.currentPhoto allowDownload:allowDownload] autorelease];
	[self.photoOptionActionSheetController showOptions];
}

- (void)showCommentsAction:(id)sender
{
	if ( isRotating || isDeleting )
	{
		return;
	}

	NSLog( @"Show Comments button for photoId: %@", self.currentPhoto.photoId );

	NSString *actionPath;

	if ( [sender isKindOfClass:[UITextField class]] )
	{
		// We are responding to a click in the comment entry fields - display comments view but enter into comment post form directly
		actionPath = [NSString stringWithFormat:@"tt://photoComments/post/%@", self.currentPhoto.photoId];
	}
	else
	{
		actionPath = [NSString stringWithFormat:@"tt://photoComments/%@", self.currentPhoto.photoId];
	}

	[UIView beginAnimations:@"animation" context:nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
	[UIView setAnimationDuration:.7];
	[UIView commitAnimations];

	PhotoCommentsListTableViewController *commentsTableView = (PhotoCommentsListTableViewController *) [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:actionPath] applyAnimated:YES]];
	commentsTableView.photoModel = self.currentPhoto;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Override so we can set our own PhotoView
//
/*
 - (TTPhotoView*)createPhotoView {
 return [[[PhotoView alloc] init] autorelease];
 }
 */

#pragma mark UIViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView
{
	CGRect screenFrame = [UIScreen mainScreen].bounds;
	self.view = [[[UIView alloc] initWithFrame:screenFrame] autorelease];

	CGRect innerFrame = CGRectMake( 0, 0,
			screenFrame.size.width, screenFrame.size.height );
	_innerView = [[UIView alloc] initWithFrame:innerFrame];
	_innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_innerView];

	_scrollView = [[TTScrollView alloc] initWithFrame:screenFrame];
	_scrollView.delegate = self;
	_scrollView.dataSource = self;
	_scrollView.rotateEnabled = NO;
	_scrollView.backgroundColor = [UIColor blackColor];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_innerView addSubview:_scrollView];

	UIBarButtonItem *playButton =
			[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
														   target:self
														   action:@selector(playAction)]
					autorelease];
	playButton.tag = 1;

	self.likeButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kAssetLikeIcon]
														style:UIBarButtonItemStylePlain
													   target:self
													   action:@selector(likeAction:)] autorelease];
	[self updateLikeButton];

	self.shareButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																	  target:self
																	  action:@selector(photoOptionAction:)] autorelease];

	self.commentButton = [[[CommentButtonView alloc] initWithFrame:CGRectMake( 0.0, 0.0, 30.0, 30.0 )
															target:self
															action:@selector(showCommentsAction:)] autorelease];
	[self.commentButton setTag:kCommentButtonTag];

	UIBarItem *commentBarButton = [[[UIBarButtonItem alloc] initWithCustomView:self.commentButton] autorelease];

	UIBarItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																	  target:nil action:nil] autorelease];

	[self updateDeleteButtonEnabled];
	[self updateRotationButtonEnabled];

	_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake( 0, screenFrame.size.height - TT_ROW_HEIGHT, screenFrame.size.width, TT_ROW_HEIGHT )];
	if ( self.navigationBarStyle == UIBarStyleDefault )
	{
		_toolbar.tintColor = TTSTYLEVAR( toolbarTintColor );
	}

	_toolbar.barStyle = self.navigationBarStyle;
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

	_toolbar.items = [NSArray arrayWithObjects:self.shareButton, space, self.likeButton, space, commentBarButton, space, playButton, space, _rotateRightBarButton, space, _deleteBarButton, nil];

	[_innerView addSubview:_toolbar];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	isDeleting = NO;
	isRotating = NO;

	self.navigationBarStyle = UIBarStyleBlackTranslucent;
	self.navigationBarTintColor = nil;

	slideshowLength = [[SettingsModel settings] slideshowTransitionLength];

	if ( self.autoPlay )
	{
		self.autoPlay = NO;
		[self playAction];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didApplicationBecomeInactiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	isDeleting = NO;
	isRotating = NO;

	// Register to receive touch events
	MobileAppAppDelegate *appDelegate = (MobileAppAppDelegate *) [[UIApplication sharedApplication] delegate];
	EventInterceptWindow *window = (EventInterceptWindow *) appDelegate.window;
	window.eventInterceptDelegate = self;

	[self showTipsAlways:NO];

	[self updateToolbarButtons];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// Deregister from receiving touch events
	MobileAppAppDelegate *appDelegate = (MobileAppAppDelegate *) [[UIApplication sharedApplication] delegate];
	EventInterceptWindow *window = (EventInterceptWindow *) appDelegate.window;
	window.eventInterceptDelegate = nil;

	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

/*
 If we get to the single photo view from the notification screen, we need to replace the back
 button with a custom image and add a right nav button that takes the user to the album view.
 */
- (void)updateNavigationBarItemsForNotificationInNavigationHistory
{
	if ( [self isNotificationsScreenInNavigationHistory] )
	{
		NSString *albumTitle = [[[AlbumListModel albumList] albumFromAlbumId:_albumId] name];
		self.navigationItem.hidesBackButton = YES;

		// Truncate string.  TODO: This would make a good utility method - truncateToLength:appendWith:
		NSUInteger len = 17;
		if ( [albumTitle length] > len )
		{
			albumTitle = [[albumTitle substringToIndex:len] stringByAppendingString:@".."];
		}

		UIButton *leftNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *image = [UIImage imageNamed:kAssetNotificationsIcon];

		[leftNavButton setBackgroundImage:image forState:UIControlStateNormal];
		[leftNavButton addTarget:self action:@selector(returnToNotifications) forControlEvents:UIControlEventTouchUpInside];

		leftNavButton.frame = CGRectMake( 0.0, 0.0, image.size.width, image.size.height );

		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:leftNavButton] autorelease];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:albumTitle style:UIBarButtonItemStylePlain target:self action:@selector(returnToAlbum)] autorelease];

		self.navigationController.navigationBarHidden = NO;
	}
}

- (void)updateCommentsBubble
{
	NSArray *annotations = [self.pictureAnnotationsModel annotations];
	int numLikes = annotations ? [annotations count] : 0;
	int numComments = [self.currentPhoto.numComments intValue] + numLikes;
	[self.commentButton setCommentCount:[NSNumber numberWithInt:numComments]];
	NSLog( @"Update comments count: %i", numComments );
}

- (void)updateToolbarButtons
{
	[self updateLikeButton];
	[self updateCommentsBubble];
	[self updateRotationButtonEnabled];
	[self updateDeleteButtonEnabled];

	// We call this here instead of just in viewWillAppear because after [self refresh] is called
	// the rightBarButtonItem disappears.  If we run this code as part of the Three20 refresh loop
	// then the bar button remains correctly visible.
	[self updateNavigationBarItemsForNotificationInNavigationHistory];
}


- (void)updateDeleteButtonEnabled
{
	AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
	BOOL deleteEnabled = [[UserModel userModel] canDeletePhoto:self.currentPhoto inAlbum:album];

	if ( deleteEnabled )
	{
		// If the button is currently disabled, we need to swap it out, otherwise no need to do anything.
		if ( _deleteBarButton == nil || _deleteBarButton.tag == kToolbarDeleteButtonDisabledTag )
		{
			[_deleteBarButton release];
			_deleteBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhotoAction:)];
			_deleteBarButton.tag = kToolbarDeleteButtonTag;
			[_toolbar replaceItemWithTag:kToolbarDeleteButtonDisabledTag withItem:_deleteBarButton];
		}	
	}
	else
	{
		// If the button is currently enabled, we need to swap it out, otherwise no need to do anything.
		if ( _deleteBarButton == nil || _deleteBarButton.tag == kToolbarDeleteButtonTag )
		{
			[_deleteBarButton release];
			_deleteBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kAssetDeleteDisabledIcon]
																					style:UIBarButtonItemStylePlain
																				   target:self
																				   action:@selector(deletePhotoAction:)];
			_deleteBarButton.tag = kToolbarDeleteButtonDisabledTag;
			[_toolbar replaceItemWithTag:kToolbarDeleteButtonTag withItem:_deleteBarButton];
		}
	}
}

- (void)updateRotationButtonEnabled
{
	// First, create the rotate button if it doesn't exist yet.
	if ( !_rotateRightBarButton )
	{
		_rotateRightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kAssetRotateRightIcon]
																				  style:UIBarButtonItemStylePlain
																				 target:self
																				 action:@selector(rotateImageAction:)];
		[_rotateRightBarButton setTag:kRotateRightButtonTag];
	}
	
	// Assign the correct UIImage for the rotate button based on the enabled state
	AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
	BOOL rotateEnabled = [[UserModel userModel] canRotatePhoto:self.currentPhoto inAlbum:album];
	if ( rotateEnabled )
	{
		_rotateRightBarButton.image = [UIImage imageNamed:kAssetRotateRightIcon];

	}
	else
	{
		_rotateRightBarButton.image = [UIImage imageNamed:kAssetRotateRightDisabledIcon];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( [keyPath isEqualToString:@"annotations"] )
	{
		[self updateLikeButton];
		[self updateCommentsBubble];
	}
}

#pragma mark - Like and Unlike

- (void)updateLikeButton
{
	self.likeButton.image = [UIImage likeImageForPhoto:[self.currentPhoto.photoId stringValue]];
	self.likeButton.enabled = YES;	
}

- (void)likeAction:(id)sender
{
	self.likeButton.enabled = NO;

	_pictureAnnotationsModel.delegate = self;
	[_pictureAnnotationsModel toggleLike];

	self.hud.labelText = [AlbumAnnotationsModel userLikesPhoto:self.currentPhoto.photoId] ? @"Unliking photo..." : @"Liking photo...";
	[self.hud show:YES];
}

#pragma mark - AlbumPicturesAnnotationsModelDelegate

- (void)showTemporaryHudImage:(NSString *)imageName withMessage:(NSString *)message
{
	self.hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
	self.hud.labelText = message;
	self.hud.mode = MBProgressHUDModeCustomView;
	[self.hud show:YES];
	double delayInSeconds = 1;
	dispatch_after( dispatch_time( DISPATCH_TIME_NOW, (int64_t) ( delayInSeconds * NSEC_PER_SEC ) ), dispatch_get_current_queue(), ^
	{
		[_hud hide:YES];
	} );
}

- (void)didLikeSucceed:(AlbumPicturesAnnotationsModel *)model;
{
	model.delegate = nil;

	// Show the like feedback for 1 second
	[self showTemporaryHudImage:kAssetLikeIcon withMessage:@"Liked"];
}

- (void)didLikeFail:(AlbumPicturesAnnotationsModel *)model  error:(NSError *)error;
{
	model.delegate = nil;
	[_hud hide:YES];

	NSLog( @"AddLike failed!" );
}


- (void)didUnLikeSucceed:(AlbumPicturesAnnotationsModel *)model;
{
	model.delegate = nil;

	// Show the like feedback for 1 second
	[self showTemporaryHudImage:kAssetUnlikeIcon withMessage:@"Unliked"];
}

- (void)didUnLikeFail:(AlbumPicturesAnnotationsModel *)model  error:(NSError *)error;
{
	model.delegate = nil;
	[_hud hide:YES];
	NSLog( @"Unlike failed!" );
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark TTScrollViewDelegate

- (void)scrollViewWillBeginDragging:(TTScrollView *)scrollView
{
	if ( _slideShowActive )
	{
		[self pauseAction];
	}

	[super scrollViewWillBeginDragging:scrollView];
}

- (void)scrollView:(TTScrollView *)scrollView tapped:(UITouch *)touch
{
	if ( _slideShowActive )
	{
		[self pauseAction];
	}
    
    // Toggle the current full screen behavior.
    [self consumeFullScreen:!barsAreHidden];
}

#pragma mark ShareActionSheetControllerDelegate

- (UIView *)view
{
	return [super view];
}

- (BOOL)interceptEvent:(UIEvent *)event
{
	if ( _tipView != nil && _tipView.targetObject != nil )
	{
		[_tipView dismissAnimated:YES];
		[[SettingsModel settings] setTipDisplayedCommentsButton:YES];
	}
	return NO;
}

#pragma mark - MBProgress HUD

- (MBProgressHUD *)hud
{
	if ( !_hud )
	{
		_hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		_hud.delegate = self;
		_hud.removeFromSuperViewOnHide = YES;
		[self.navigationController.view addSubview:_hud];
	}

	return _hud;
}

- (void)hudWasHidden
{
	TT_RELEASE_SAFELY(_hud)
}

@end

