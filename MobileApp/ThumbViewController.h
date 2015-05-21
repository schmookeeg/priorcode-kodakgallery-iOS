//
//  PhotoViewController.h
//  KGDemo
//
//  Created by mikeb on 5/20/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "AlbumPhotoSource.h"
#import "ShareActionSheetControllerDelegate.h"
#import "AlbumShareActionSheetController.h"
#import "PhotoOptionActionSheetController.h"
#import "CMPopTipView.h"
#import "EventInterceptWindow.h"
#import "MBProgressHUD.h"
#import "AlbumModelDelegate.h"
#import "AlbumListModelDelegate.h"
#import "SelectPhotosViewControllerDelegate.h"

@class AlbumOptionsActionSheetController;
@class PrintsAddedModalAlertView;

@interface ThumbViewController : TTThumbsViewController <ShareActionSheetControllerDelegate, EventInterceptWindowDelegate, AlbumModelDelegate, UIActionSheetDelegate, MBProgressHUDDelegate, UIAlertViewDelegate, AlbumListModelDelegate, SelectPhotosViewControllerDelegate>
{
	NSNumber *_albumId;
	int _enabledAlbumOptions;
	AlbumPhotoSource *_photoSet;
	UIBarButtonItem *_uploadButton;

	NSNumber *_photoId;
	UIToolbar *_toolbar;
	UIBarButtonItem *_playButton;
	UIBarButtonItem *_optionsButton;
	UIBarButtonItem *_membersButton;
	UIBarButtonItem *_deleteButton;
    UIBarButtonItem *_editButton;

	BOOL _scrollToBottom;

	AlbumShareActionSheetController *_albumShareActionSheetController;
	PhotoOptionActionSheetController *_photoShareActionSheetController;
    AlbumOptionsActionSheetController *_albumOptionsActionSheetController;
    PrintsAddedModalAlertView *_printsAddedModalAlertView;

	CMPopTipView *_tipView;
	CMPopTipView *_tipViewShare;

	MBProgressHUD *_hud;

	SEL _postRefreshSelector;
    BOOL _showAddedToPrints;


}

typedef enum { ThumbNavigation, SelectPrints } VIEW_MODE;


@property ( nonatomic, retain ) MBProgressHUD *hud;
@property ( nonatomic, retain ) AlbumShareActionSheetController *albumShareActionSheetController;
@property ( nonatomic, retain ) AlbumOptionsActionSheetController *albumOptionsActionSheetController;
@property ( nonatomic, retain ) PhotoOptionActionSheetController *photoShareActionSheetController;
@property(nonatomic, retain) PrintsAddedModalAlertView *printsAddedModalAlertView;
@property ( nonatomic, retain ) AlbumPhotoSource *photoSet;
@property ( nonatomic, retain ) NSNumber *albumId;
@property ( nonatomic, retain ) NSNumber *photoId;
@property ( nonatomic ) int enabledAlbumOptions;
@property ( nonatomic ) BOOL scrollToBottom;
@property ( nonatomic ) VIEW_MODE viewMode;

- (id)initWithAlbumId:(NSString *)albumId;

- (id)initPhotoWithAlbumId:(NSString *)albumId;

- (id)initPhotoWithAlbumId:(NSString *)albumId photoId:(NSString *)photoId;

- (void)initToolBar;

- (UIEdgeInsets)edgeInsetsRetracted;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)configureDeleteButton;

- (void)deleteAlbum;

@end
