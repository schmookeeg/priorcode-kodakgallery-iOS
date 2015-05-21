//
//  SettingsModel.h
//  MobileApp
//
//  Created by Jon Campbell on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractAlbumModel.h"

@interface SettingsModel : NSObject
{
	BOOL uploadNotification;
	BOOL albumJoinNotification;
	BOOL likeNotification;
	BOOL commentsNotification;
	BOOL albumListAnonymousWarningShown;
	BOOL resizeImagesOnUpload;
	BOOL tipDisplayedNewAlbumButton;
	BOOL tipDisplayedUploadButton;
	BOOL tipDisplayedCommentButton;
	BOOL tipDisplayedPrintsTab;
	BOOL welcomeGroupMessageDisplayed;
	BOOL welcomeGeneralMessageDisplayed;
	BOOL welcomeFriendMessageDisplayed;
	BOOL pendingShareTokenChecked;

	int slideshowTransitionLength;
	int notificationBitMask;
	NSUserDefaults *defaultSettings;
}

- (int)slideshowTransitionLength;

- (void)setSlideshowTransitionLength:(int)length;

- (BOOL)uploadNotification;

- (void)setUploadNotification:(BOOL)on;

- (BOOL)albumJoinNotification;

- (void)setAlbumJoinNotification:(BOOL)on;

- (BOOL)likeNotification;

- (void)setLikeNotification:(BOOL)on;

- (BOOL)resizeImagesOnUpload;

- (void)setResizeImagesOnUpload:(BOOL)on;

- (BOOL)commentsNotification;

- (void)setCommentsNotification:(BOOL)on;

- (BOOL)tipDisplayedUploadButton;

- (void)setTipDisplayedUploadButton:(BOOL)on;

- (BOOL)tipDisplayedNewAlbumButton;

- (void)setTipDisplayedNewAlbumButton:(BOOL)on;

- (BOOL)tipDisplayedCommentsButton;

- (void)setTipDisplayedCommentsButton:(BOOL)on;

@property ( nonatomic, assign ) BOOL tipDisplayedPhotoHole;
- (BOOL)tipDisplayedPrintsTab;

- (void)setTipDisplayedPrintsTab:(BOOL)on;

- (BOOL)welcomeGroupMessageDisplayed;

- (void)setWelcomeGroupMessageDisplayed:(BOOL)on;

- (BOOL)welcomeGeneralMessageDisplayed;

- (void)setWelcomeGeneralMessageDisplayed:(BOOL)on;

- (BOOL)welcomeFriendMessageDisplayed;

- (void)setWelcomeFriendMessageDisplayed:(BOOL)on;

- (BOOL)pendingShareTokenChecked;

- (void)setPendingShareTokenChecked:(BOOL)on;


- (int)notificationBitMask;

@property ( nonatomic ) BOOL albumListAnonymousWarningShown;


+ (SettingsModel *)settings;

@end
