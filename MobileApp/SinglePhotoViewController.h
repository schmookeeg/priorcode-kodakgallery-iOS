//
//  SinglePhotoViewController.h
//  MobileApp
//
//  Created by mikeb on 6/2/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "AlbumPhotoSource.h"
#import "CommentButtonView.h"
#import "ShareActionSheetControllerDelegate.h"
#import "PhotoOptionActionSheetController.h"
#import "CMPopTipView.h"
#import "EventInterceptWindow.h"
#import "PhotoModelDelegate.h"
#import "UserModel.h"
#import "MBProgressHUD.h"

@interface SinglePhotoViewController : TTPhotoViewController <ShareActionSheetControllerDelegate, EventInterceptWindowDelegate, PhotoModelDelegate, UIActionSheetDelegate, MBProgressHUDDelegate, AlbumPicturesAnnotationsModelDelegate>
{
	int slideshowLength;
	NSNumber *_albumId;
	AlbumPhotoSource *_photoSet;

	// Storage for the annotations model of the currently displayed photo.  We keep a reference
	// around to this because we need to use KVO to make sure the comment and like button status
	// remains in sync whenever the picture annotations change.
	AlbumPicturesAnnotationsModel *_pictureAnnotationsModel;

	UIBarButtonItem *_likeButton;
	CommentButtonView *_commentButton;
	UIBarButtonItem *_shareButton;

	UIBarItem *_deleteBarButton;
	UIBarItem *_rotateRightBarButton;

	BOOL _slideShowActive;
	BOOL _autoPlay;

	PhotoOptionActionSheetController *_photoOptionActionSheetController;
	CMPopTipView *_tipView;

	MBProgressHUD *_hud;

	BOOL isDeleting;
	BOOL isRotating;
    BOOL receivedPhotoRotateResponse;
    
    BOOL barsAreHidden;
}

@property ( nonatomic, retain ) PhotoOptionActionSheetController *photoOptionActionSheetController;
@property ( nonatomic, readonly ) MBProgressHUD *hud;

@property ( nonatomic, retain ) AlbumPhotoSource *photoSet;
@property ( nonatomic, retain ) NSNumber *albumId;
@property ( nonatomic, retain ) AlbumPicturesAnnotationsModel *pictureAnnotationsModel;

@property ( nonatomic, retain ) UIBarButtonItem *likeButton;
@property ( nonatomic, retain ) CommentButtonView *commentButton;
@property ( nonatomic, retain ) UIBarButtonItem *shareButton;

@property ( nonatomic ) BOOL autoPlay;

- (void)pauseAction;

- (BOOL)isNotificationsScreenInNavigationHistory;

- (void)returnToNotifications;

- (void)returnToAlbum;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)deletePhoto;

- (void)updateToolbarButtons;

- (void)updateLikeButton;

- (void)updateDeleteButtonEnabled;

- (void)updateDeleteButtonEnabledAndHideDeletingMessage;

- (void)updateRotationButtonEnabled;

- (void)updateRotationButtonEnabledAndHideRotatingMessage;

@end
