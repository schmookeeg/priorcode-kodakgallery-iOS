//
//  PhotoViewController.m
//  KGDemo
//
//  Created by Dev on 5/20/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "SinglePhotoViewController.h"
#import "AlbumListModel.h"
#import "MemberListTableViewController.h"
#import "SettingsModel.h"
#import "ThumbViewDragRefreshDelegate.h"
#import "MobileAppAppDelegate.h"
#import "EmptyAlbumsView.h"
#import "UserModel+Permissions.h"
#import "AlbumOptionsActionSheetController.h"
#import "PrintsAddedModalAlertView.h"
#import "CartModel.h"

@implementation ThumbViewController

@synthesize photoSet = _photoSet;
@synthesize albumId = _albumId;
@synthesize photoId = _photoId;
@synthesize albumShareActionSheetController = _albumShareActionSheetController;
@synthesize photoShareActionSheetController = _photoShareActionSheetController;
@synthesize enabledAlbumOptions = _enabledAlbumOptions;
@synthesize scrollToBottom = _scrollToBottom;
@synthesize hud = _hud;
@synthesize albumOptionsActionSheetController = _albumOptionsActionSheetController;
@synthesize printsAddedModalAlertView = _printsAddedModalAlertView;
@synthesize viewMode;

- (id)initWithPostUploadAlbumId:(NSString *)albumId {
    self = [self initWithAlbumId:albumId];

    if (self) {
        _scrollToBottom = YES;
    }

    return self;
}

- (void)setupPhotoSource {
    AlbumPhotoSource *photoSource = [[AlbumPhotoSource alloc] initWithAlbumId:self.albumId];
    self.photoSource = photoSource;
    [photoSource release];

    self.albumShareActionSheetController = [[[AlbumShareActionSheetController alloc] initWithDelegate:self album:((AlbumPhotoSource *) self.photoSource).album] autorelease];
    self.albumOptionsActionSheetController = [[[AlbumOptionsActionSheetController alloc] initWithDelegate:self album:((AlbumPhotoSource *) self.photoSource).album] autorelease];
}

- (id)initWithAlbumId:(NSString *)albumId; {
    self = [super init];

    if (self) {
        self.albumId = [NSNumber numberWithDouble:[albumId doubleValue]];
        self.photoId = nil;

        _enabledAlbumOptions = [[[AlbumListModel albumList] albumFromAlbumId:self.albumId] enabledOptions];

        [self setupPhotoSource];

        // See https://jc.ofoto.com/jira/browse/STABTWO-1941
        if ([(AlbumPhotoSource *) self.photoSource isAlbumNotAccessible]) {
            // It's possible that the album was deleted.  It's also possible that we have a notification for
            // an event in a album that we don't have in our album list yet.  So, to handle the latter case
            // let's reload the album list.  We'll try to create a photo source for the album again and
            // if it fails again that means the album is officially deleted.
            AlbumListModel *albumList = [AlbumListModel albumList];
            albumList.delegate = self;
            [albumList fetch];
        }

        _deleteButton = nil;
        _showAddedToPrints = NO;
        _scrollToBottom = NO;
    }

    return self;
}

- (id)initPhotoWithAlbumId:(NSString *)albumId {
    PhotoModel *photo = (PhotoModel *) [[self photoSource] photoAtIndex:0];

    self = [self initPhotoWithAlbumId:albumId photoId:[NSString stringWithFormat:@"%@", [photo photoId]]];

    return self;
}

- (id)initPhotoWithAlbumId:(NSString *)albumId photoId:(NSString *)photoId {
    self = [self initWithAlbumId:albumId];

    self.photoId = [NSNumber numberWithDouble:[photoId doubleValue]];

    return self;
}

- (void)initToolBar {
    CGRect screenFrame = [UIScreen mainScreen].bounds;

    _optionsButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                    target:self.albumOptionsActionSheetController
                                                                    action:@selector(showOptions)] autorelease];

    _playButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                 target:self
                                                                 action:@selector(playPhotos)] autorelease];

    UIImage *editImage = [UIImage imageNamed:kAssetEditAlbumIcon];

    _editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                   target:self
                                                   action:@selector(editAlbum)] autorelease];
    [self configureDeleteButton];

    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
            UIBarButtonSystemItemFlexibleSpace                              target:nil action:nil] autorelease];

    if ((_enabledAlbumOptions & kAlbumTypeOptionEnableMemberList) == kAlbumTypeOptionEnableMemberList) {
        _membersButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kAssetFriendListIcon]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(refreshAndShowMemberList)] autorelease];
    }
    else {
        _membersButton = nil;
    }

    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, screenFrame.size.height - TT_ROW_HEIGHT, screenFrame.size.width, TT_ROW_HEIGHT)];
    if (self.navigationBarStyle == UIBarStyleDefault) {
        _toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
    }

    _toolbar.barStyle = self.navigationBarStyle;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    NSArray *objectsArray;

/*	if ( _membersButton )
	{
		objectsArray = [NSArray arrayWithObjects:_shareButton, space, _editButton, space, _playButton, space, _deleteButton, space, _membersButton, nil];
	}
	else
	{
		objectsArray = [NSArray arrayWithObjects:_shareButton, space,  _editButton, space, _playButton, space, _deleteButton, nil];
	}*/

    AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];

    int albumType = [[album type] intValue];
    switch (albumType) {

        case 91:
            objectsArray = [NSArray arrayWithObjects:_optionsButton, space, _playButton, space, _deleteButton, nil];
            break;

        case 0:
            objectsArray = [NSArray arrayWithObjects:_optionsButton, space, _editButton, space, _playButton, space, _deleteButton, nil];
            break;

        case 101:
        {
            if (_membersButton) {
                if ([[UserModel userModel] canEditAlbum:album])
                    objectsArray = [NSArray arrayWithObjects:_optionsButton, space, _editButton, space, _playButton, space, _deleteButton, space, _membersButton, nil];
                else
                    objectsArray = [NSArray arrayWithObjects:_optionsButton, space, _editButton, space, _playButton, space, _membersButton, nil];
            }
            else {
                if ([[UserModel userModel] canEditAlbum:album])
                    objectsArray = [NSArray arrayWithObjects:_optionsButton, space, _editButton, space, _playButton, space, _deleteButton, nil];
                else
                    objectsArray = [NSArray arrayWithObjects:_optionsButton, space, _editButton, space, _playButton, space, nil];
            }
            break;
        }

    }

    _toolbar.items = objectsArray;

    [[self.tableView superview] addSubview:_toolbar];
}

- (void)configureDeleteButton {
    AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
    if ([[UserModel userModel] canEditAlbum:album]) {
        // If the button is currently disabled, we need to swap it out, otherwise no need to do anything.
        if (_deleteButton == nil || _deleteButton.tag == kToolbarDeleteButtonDisabledTag) {
            [_deleteButton release];
            _deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonAction:)];
            _deleteButton.tag = kToolbarDeleteButtonTag;
            [_toolbar replaceItemWithTag:kToolbarDeleteButtonDisabledTag withItem:_deleteButton];
        }
    }
    else {
        // If the button is currently enabled, we need to swap it out, otherwise no need to do anything.
        if (_deleteButton == nil || _deleteButton.tag == kToolbarDeleteButtonTag) {
            [_deleteButton release];
            _deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kAssetDeleteDisabledIcon]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(deleteButtonAction:)];
            _deleteButton.tag = kToolbarDeleteButtonDisabledTag;
            [_toolbar replaceItemWithTag:kToolbarDeleteButtonTag withItem:_deleteButton];
        }
    }
}

- (UIEdgeInsets)edgeInsetsRetracted {
    return UIEdgeInsetsMake(4, 0, TTToolbarHeight(), 0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateTableLayout {
    self.tableView.contentInset = [self edgeInsetsRetracted];
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(TTBarsHeight(), 0, 0, 0);
}

- (void)showTipsAlways:(BOOL)alwaysShow {
	
	if (self.viewMode != ThumbNavigation) {
		// Bypass tips if we're navigating thumbnails to do select something like prints
		return;
	}
	
    if (alwaysShow || ![[SettingsModel settings] tipDisplayedUploadButton]) {
        // Haven't displayed the upload tip
        if (_tipView != nil && _tipView.targetObject != nil) {
            [_tipView dismissAnimated:YES];
            [_tipView release];
        }
        _tipView = [[[CMPopTipView alloc] initWithMessage:@"Tap here to add\nphotos to this album."] retain];
        _tipView.backgroundColor = POPTIP_BACKGROUND_COLOR;
        _tipView.textColor = POPTIP_TEXT_COLOR;
        _tipView.delegate = nil;
        _tipView.animation = CMPopTipAnimationPop;
        [_tipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];

        // Haven't displayed the share tip - we're using the tipDisplayedUploadButton flag since they are on the same screen
        if (_tipViewShare != nil && _tipViewShare.targetObject != nil) {
            [_tipViewShare dismissAnimated:YES];
            [_tipViewShare release];
        }
        _tipViewShare = [[[CMPopTipView alloc] initWithMessage:@"Tap here to buy prints\nor share this album"] retain];
        _tipViewShare.backgroundColor = POPTIP_BACKGROUND_COLOR;
        _tipViewShare.textColor = POPTIP_TEXT_COLOR;
        _tipViewShare.delegate = nil;
        _tipViewShare.animation = CMPopTipAnimationPop;
        [_tipViewShare presentPointingAtBarButtonItem:_optionsButton animated:YES];

    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];

    [self initToolBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.navigationBarStyle = UIBarStyleBlack;
    self.navigationBarTintColor = nil;

    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressFrom:)];
    [self.tableView addGestureRecognizer:longPressGestureRecognizer];
    [longPressGestureRecognizer release];

    if (!_uploadButton) {
        UIImage *image = [UIImage imageNamed:@"UploadIcon.png"];
        _uploadButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(uploadPhotos)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	self.viewMode = ThumbNavigation;

    if (_photoId) {
        self.navigationController.navigationBarHidden = YES;
    }
    else {
        self.navigationController.navigationBarHidden = NO;
    }

    if ((_enabledAlbumOptions & kAlbumTypeOptionEnableUpload) == kAlbumTypeOptionEnableUpload) {
        self.navigationItem.rightBarButtonItem = _uploadButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didApplicationBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

    _albumShareActionSheetController.delegate = self;

    AlbumPhotoSource *photoSource = (AlbumPhotoSource *) self.photoSource;

    if ([AlbumPhotoSource albumDirty]) {
        [AlbumPhotoSource setAlbumDirty:NO];
        [photoSource refresh];
    }

    // Hide the toolbar until the model finishes loading.
    _toolbar.hidden = [photoSource isLoading] || [photoSource isAlbumNotAccessible];

    if (_albumId != nil) {
        AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
        self.navigationItem.title = [album name];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Register to receive touch events
    MobileAppAppDelegate *appDelegate = (MobileAppAppDelegate *) [[UIApplication sharedApplication] delegate];
    EventInterceptWindow *window = (EventInterceptWindow *) appDelegate.window;
    window.eventInterceptDelegate = self;

    [self showTipsAlways:NO];

    [self.view bringSubviewToFront:_toolbar];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Deregister from receiving touch events
    MobileAppAppDelegate *appDelegate = (MobileAppAppDelegate *) [[UIApplication sharedApplication] delegate];
    EventInterceptWindow *window = (EventInterceptWindow *) appDelegate.window;
    window.eventInterceptDelegate = nil;


    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidUnload {
    TT_RELEASE_SAFELY( _uploadButton );

    [super viewDidUnload];
}

- (void)didApplicationBecomeActiveNotification:(NSNotification *)notification {
    if ([[[TTNavigator navigator] visibleViewController] isEqual:self]) {
        [[self photoSource] invalidate:YES];
        [self reload];
    }
}

#pragma mark - MBProgress HUD

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.delegate = self;
        _hud.removeFromSuperViewOnHide = YES;
        [self.navigationController.view addSubview:_hud];
    }

    return _hud;
}

- (void)hudWasHidden {
    TT_RELEASE_SAFELY(_hud)
}


#pragma mark -

- (void)modelDidFinishLoad:(id <TTModel>)model {
    [super modelDidFinishLoad:model];

    NSLog(@"ThumbViewController - model loaded");
    self.navigationItem.title = [(id <TTPhotoSource>) model title];

    if (_photoId) {
        PhotoModel *photo = [[(AlbumPhotoSource *) [self photoSource] album] photoFromId:_photoId];

        TTPhotoViewController *controller = [self createPhotoViewController];
        controller.centerPhoto = photo;

        [self.navigationController pushViewController:controller animated:NO];

        self.photoId = nil;

        return;
    }

    // scroll to bottom if we come from an upload view
    if (_scrollToBottom) {
        NSInteger row = [self.tableView numberOfRowsInSection:0] - 1;
        // Only reset the table scroll if there are contents in the table
        if (row >= 0) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }

    // Don't go through the property to get the hud because we don't want to create it
    // if it doesn't exist, since all we're doing is telling it to hide.
    [_hud hide:YES];

    if (_postRefreshSelector != nil && [self respondsToSelector:_postRefreshSelector]) {
        [self performSelector:_postRefreshSelector];
    }

    _toolbar.hidden = NO;
    [self.view bringSubviewToFront:_toolbar];
}

- (void)editAlbum {

    NSString *actionUrl = [NSString stringWithFormat:@"tt://editAlbum/%@", _albumId];

    TTURLAction *action = [TTURLAction actionWithURLPath:actionUrl];
    action.animated = YES;
    [[TTNavigator navigator] openURLAction:action];
}

- (void)uploadPhotos {
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://upload/%@", self.albumId]]];
}

- (void)playPhotos {
    if ([_photoSource numberOfPhotos] > 0) {
        SinglePhotoViewController *controller = (SinglePhotoViewController *) [self createPhotoViewController];
        controller.autoPlay = YES;
        controller.centerPhoto = [_photoSource photoAtIndex:0];
        controller.albumId = self.albumId;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)handleLongPressFrom:(UILongPressGestureRecognizer *)recognizer {
    // Only process when the gesture is first recognized.
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint gesturePoint = [recognizer locationInView:self.tableView];

        // Find the view that actually triggered the long press (since the gesture recognizer is on
        // the table and not on each invidual cell, we can't just ask for recognizer.view because it
        // will always be the table view that triggered it).
        UIView *longPressThumbView = [self.tableView hitTest:gesturePoint withEvent:nil];
        if (![longPressThumbView isKindOfClass:[TTThumbView class]]) {
            // Did not long press on one of the thumb views in the table (might have long pressed
            // in an open space, in which case we don't have a photo to act upon)
            return;
        }

        // Find the cell renderer in the table that triggers the long press
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:gesturePoint];
        TTThumbsTableViewCell *cell = (TTThumbsTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];

        // Loop through the cell renderer children to match the thumb that triggered
        // the long press.  We have to do this to find the right photo behind the press.
        PhotoModel *longPressedPhoto = nil;
        NSUInteger i = 0;
        for (TTThumbView *thumbView in cell.contentView.subviews) {
            if (thumbView == longPressThumbView) {
                NSUInteger thumbViewIndex = i;
                NSInteger offsetIndex = cell.photo.index + thumbViewIndex;

                id <TTPhoto> photo = [cell.photo.photoSource photoAtIndex:offsetIndex];
                longPressedPhoto = (PhotoModel *) photo;
                break;
            }
            i++;
        }

        // Finally, if we were able to find a photo model that was long pressed, then we
        // can show the single photo options action sheet.
        if (longPressedPhoto != nil) {
            AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
            BOOL allowDownload = [[UserModel userModel] canDownloadPhoto:longPressedPhoto fromAlbum:album];

            self.photoShareActionSheetController = [[[PhotoOptionActionSheetController alloc] initWithDelegate:self album:album photo:longPressedPhoto allowDownload:allowDownload] autorelease];
            [self.photoShareActionSheetController showOptions];
        }

    }
}

#pragma mark - Confirm Album Delete

- (void)deleteButtonAction:(id)sender {
    AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
    if ([[UserModel userModel] canEditAlbum:album]) {
        UIActionSheet *confirmDeleteActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                                     cancelButtonTitle:@"Cancel"
                                                                destructiveButtonTitle:@"Delete Album"
                                                                     otherButtonTitles:nil];
        [confirmDeleteActionSheet showInView:self.view];
        [confirmDeleteActionSheet release];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Delete Album"
                                                            message:@"Only the owner of this album can delete the album."
                                                           delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];

        [alertView show];
        [alertView autorelease];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [self deleteAlbum];
    }
}

- (void)deleteAlbum {
    self.hud.labelText = @"Deleting album...";
    [self.hud show:YES];

    // FIXME This should be refactored into a category, this code exists in at least 3 different places
    // https://jc.ofoto.com/jira/browse/STABTWO-2026 - There's an issue with the MBProgressHUD subproject
    // that causes it to have the wrong bounds set in certain situations (where the device is rotated but
    // the screen is not yet updated, such as when an actionsheet is present).
    // Force the hud bounds to take on that of the superview so make sure that the user interactions
    // with the screen are disabled while the hud is up.
    dispatch_async(dispatch_get_main_queue(), ^{
        // The below lines are the same as what is in the deviceOrientationDidChange message, but
        // that's a private message we can't send so we have to do this manually.
        //[self.hud deviceOrientationDidChange];
        self.hud.bounds = self.hud.superview.bounds;
        [self.hud setNeedsDisplay];
    });

    AlbumPhotoSource *model = (AlbumPhotoSource *) self.photoSource;
    [model.album setDelegate:self];
    [model.album deleteAlbum];
}

- (void)showMemberList {
    _postRefreshSelector = nil;

    MemberListTableViewController *memberList = [[[MemberListTableViewController alloc] initWithEventAlbum:[(AlbumPhotoSource *) _photoSource album]] autorelease];

    memberList.shareActionController = _albumShareActionSheetController;
    memberList.thumbViewController = self;
    _albumShareActionSheetController.delegate = memberList;

    [UIView beginAnimations:@"animation" context:nil];
    [[self navigationController] pushViewController:memberList animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [UIView setAnimationDuration:.7];
    [UIView commitAnimations];

}

- (void)refreshAndShowMemberList {
    // Reloads the model (which contains the current member list) and then navigates to the member list controller
    _postRefreshSelector = @selector(showMemberList);

    self.hud.labelText = @"Loading...";
    [self.hud show:YES];

    [_model load:TTURLRequestCachePolicyNetwork more:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty:(BOOL)show {
    if (show) {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"EmptyThumbnailView"
                                                          owner:self
                                                        options:nil];
        EmptyAlbumsView *emptyAlbumsView = (EmptyAlbumsView *) [nibViews objectAtIndex:0];


        self.emptyView = emptyAlbumsView;

        self.emptyView.frame = [self rectForOverlayView];

        _tableView.dataSource = nil;
        [_tableView reloadData];

        [self showTipsAlways:YES];

        AlbumPhotoSource *photoSource = (AlbumPhotoSource *) self.photoSource;

        if (![[photoSource album] isEventAlbum]) {
            UIBarButtonItem *share = (UIBarButtonItem *) [_toolbar.items objectAtIndex:0];
            [share setEnabled:NO];
        }

        AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];

        if ([[album type] intValue] == kFriendAlbumType) {
            UIBarButtonItem *play = (UIBarButtonItem *) [_toolbar.items objectAtIndex:2];
            [play setEnabled:NO];
        }
        else {
            UIBarButtonItem *play = (UIBarButtonItem *) [_toolbar.items objectAtIndex:4];
            [play setEnabled:NO];
        }
    }
    else {
        self.emptyView = nil;

        UIBarButtonItem *share = (UIBarButtonItem *) [_toolbar.items objectAtIndex:0];
        [share setEnabled:YES];

        AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];

        if ([[album type] intValue] == kMyAlbumType) {
            UIBarButtonItem *play = (UIBarButtonItem *) [_toolbar.items objectAtIndex:4];
            [play setEnabled:YES];
        }
        else if ([[album type] intValue] == kFriendAlbumType) {
            UIBarButtonItem *play = (UIBarButtonItem *) [_toolbar.items objectAtIndex:2];
            [play setEnabled:YES];
        }
        else if ([[album type] intValue] == kEventAlbumType) {
            if ([[UserModel userModel] canEditAlbum:album]) {
                UIBarButtonItem *play = (UIBarButtonItem *) [_toolbar.items objectAtIndex:4];
                [play setEnabled:YES];
            }
            else {
                UIBarButtonItem *play = (UIBarButtonItem *) [_toolbar.items objectAtIndex:2];
                [play setEnabled:YES];
            }
        }
    }
}

/**
 We override rectForOverlayView to control the sizing for the emptyView
 so that the image we display doesn't stretch.
 */
- (CGRect)rectForOverlayView {
    if (self.emptyView) {
        // Adjust the image down to account for the status and navigation bars
        /*CGRect imageFrame = self.emptyView.frame;
          UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];

          if ( deviceOrientation == UIDeviceOrientationLandscapeLeft || deviceOrientation == UIDeviceOrientationLandscapeRight )
          {
              // The empty view is designed to be displayed on a portrait screen.  If rotated we must reposition it by the diff in height/width for the two orientations
              CGFloat rotationCorrect = ( self.view.frame.size.width - ( self.view.frame.size.height + TTBarsHeight() ) ) / 2;
              imageFrame.origin.y = rotationCorrect * -1;
              imageFrame.origin.x = rotationCorrect;
          }
          else
          {
              imageFrame.origin.y = TTBarsHeight();
              imageFrame.origin.x = 0;
          }
          imageFrame.size.height = 0;

          return imageFrame;*/
        return self.view.frame;
    }
    else {
        return [super rectForOverlayView];
    }
}

#pragma mark ShareActionSheetControllerDelegate

- (UIView *)view {
    return [super view];
}

- (UINavigationController *)navigationController {
    return [super navigationController];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTPhotoViewController *)createPhotoViewController {
    SinglePhotoViewController *spvController = [[[SinglePhotoViewController alloc] init] autorelease];
    spvController.albumId = self.albumId;
    return spvController;
}


- (void)dealloc {
    TT_RELEASE_SAFELY(_photoId);
    TT_RELEASE_SAFELY(_albumId);
    TT_RELEASE_SAFELY(_photoSource);
    TT_RELEASE_SAFELY(_photoSet);

    [_albumShareActionSheetController release];
    [_photoShareActionSheetController release];
    TT_RELEASE_SAFELY(_uploadButton)

    TT_RELEASE_SAFELY(_tipView)
    TT_RELEASE_SAFELY(_tipViewShare)
    TT_RELEASE_SAFELY(_hud)

    TT_RELEASE_SAFELY(_deleteButton)
    TT_RELEASE_SAFELY(_toolbar)

    [_albumOptionsActionSheetController release];
    [_printsAddedModalAlertView release];
    [super dealloc];
}

// Add DragRefresh delegate to provide pull-to-refresh support
- (id <TTTableViewDelegate>)createDelegate {
    ThumbViewDragRefreshDelegate *delegate = [[ThumbViewDragRefreshDelegate alloc] initWithController:self];

    return [delegate autorelease];
}

- (BOOL)interceptEvent:(UIEvent *)event {
    if (_tipView != nil && _tipView.targetObject != nil) {
        [_tipView dismissAnimated:YES];
        [[SettingsModel settings] setTipDisplayedUploadButton:YES];
    }
    if (_tipViewShare != nil && _tipViewShare.targetObject != nil) {
        [_tipViewShare dismissAnimated:YES];
    }
    return NO;
}

- (void)redisplayTipsOnRotation {
    if (_tipView != nil && _tipView.targetObject != nil) {
        // Tips are current active - we'll hide them and redisplay them in their new locations
        [_tipView dismissAnimated:NO];
        [_tipViewShare dismissAnimated:NO];
        if (self.emptyView) {
            [self showTipsAlways:YES];
        }
        else {
            [self showTipsAlways:NO];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self redisplayTipsOnRotation];
    if (self.emptyView) {
        self.emptyView.frame = [self rectForOverlayView];
    }

    // FIXME: Refector this into a helper method/util/category because it's eerily similar
    // to the fix put in place for STABTWO-2026, and similar to other code in the project.
    // https://jc.ofoto.com/jira/browse/STABTWO-2029
    if (_hud) {
        _hud.bounds = _hud.superview.bounds;
        [_hud setNeedsDisplay];
    }
}

#pragma mark - AlbumListModelDelegate

/*
 We get here because we came to the ThumbViewController screen via initWithAlbumId and the
 album matching the albumId could not be found in [AlbumListModel albumList].  This delegate
 method is invoked when the albumList has been refreshed, so we're confident at this point
 that it contains valid data.
 
 If the albumId is not in the albumList as this point, we can be sure that it's been deleted.
 Otherwise, the scenario is that we tried to display an album (from the Notifications screen)
 that is not yet in memory in the album list screen itself, but the photoSource is pointing to
 a good album, so we're OK.
 */
- (void)didModelLoad:(AbstractModel *)model {
    [AlbumListModel albumList].delegate = nil;

    // Try to create the photo source again now that we have the latest album list
    // information from the server.
    [self setupPhotoSource];

    // See https://jc.ofoto.com/jira/browse/STABTWO-1941 - if the album id is not found
    // in this case then it really is gone...
    if ([(AlbumPhotoSource *) self.photoSource isAlbumNotAccessible]) {
        [[[[UIAlertView alloc] initWithTitle:@"Album Not Available"
                                     message:@"This album is no longer available."
                                    delegate:self
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] autorelease] show];

        // The view is automatically popped off the navigation stack once the
        // alert closes.
    }
    else {
        // Album list fetched OK and the photoSource is pointing to a good album now.
        // At this point we keep hiding the toolbar if photo source is loading, or display.
        _toolbar.hidden = [self.photoSource isLoading];
    }
}

- (void)didModelLoadFail:(AbstractModel *)model withError:(NSError *)error {
    [AlbumListModel albumList].delegate = nil;

    // Couldn't fetch the updated album list to try and find the new photo
    // source, so just pop back out to the notifications screen.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didModelChange:(AbstractModel *)model {
    [AlbumListModel albumList].delegate = nil;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // We only show an alert if we're trying to display an album that has been deleted, in
    // which case once the alert is closed we pop view controllers to go back to
    // where we started.
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Album delete delegate

- (void)albumDeletionSuccessWith:(AbstractAlbumModel *)model {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAnyChange"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.hud hide:YES];

    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)albumDeletionFailWith:(NSError *)error {
    [self.hud hide:YES];

    [[[[UIAlertView alloc] initWithTitle:@"Deletion Failed"
                                 message:@"Album deletion failed. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
}

#pragma mark - Select Photos View Controller Delegate

- (void)selectPhotosDidSelectPhotos:(NSArray *)photos inAlbum:(AbstractAlbumModel *)album
{
	[[CartModel cartModel] addPhotos:photos];

	int photoCount = [[CartModel cartModel] newPhotoCount];
	self.printsAddedModalAlertView = [[[PrintsAddedModalAlertView alloc] initWithPhotoCount:photoCount] autorelease];

	[self.printsAddedModalAlertView show];
}

@end
