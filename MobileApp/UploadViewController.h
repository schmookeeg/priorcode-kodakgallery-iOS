//
//  UploadViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCImagePickerController.h"
#import "UploadModelDelegate.h"
#import "MBProgressHUD.h"
#import "AlbumListModelDelegate.h"
#import "RootViewController.h"
#import "FirstTimeLocationWarningViewController.h"
#import "LocationServicesDisabledViewController.h"

@interface UploadViewController : RootViewController <ELCImagePickerControllerDelegate, UploadModelDelegate,
		UIAlertViewDelegate, AlbumListModelDelegate,
		FirstTimeLocationWarningDelegate, LocationServicesDisabledDelegate,
		UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
	UploadModel *uploadModel;
	NSString *_albumId;
	BOOL _uploadInProgress;
	BOOL _needsToShowPicker;
	UIView *_currentView;
	UIBarButtonItem *_dummyBackButton;
	int _failedUploads;

	MBProgressHUD *modelLoadingProgressView;
	UIAlertView *uploadProgressView;

	FirstTimeLocationWarningViewController *firstTimeLocationWarningViewController;
	LocationServicesDisabledViewController *locationServicesDisabledViewController;
}

@property ( nonatomic, retain ) NSString *albumId;

- (void)beginSelectAlbumFlow;

- (void)showPhotoSources;

- (void)showCamera;

- (void)showPicker;

- (void)selectAlbum;

- (void)startUpload:(NSArray *)uploads;

- (void)exitUploadView;

- (void)checkLocationEnabledAndDisplayPicker;

- (void)checkForAccessAndDisplayPicker;

@end
