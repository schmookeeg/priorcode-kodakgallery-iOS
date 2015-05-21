//
//  SettingsModel.m
//  MobileApp
//
//  Created by Jon Campbell on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsModel.h"

NSString *const kEnabledNotificationTypesKey = @"enabledNotifications";
NSString *const kSlideshowLengthKey = @"slideshowTransitionLength";
NSString *const kResizeImagesOnUpload = @"resizeImagesOnUpload";
NSString *const kTipsDisplayedUploadButtonKey = @"tipsDisplayedUploadButton";
NSString *const kTipsDisplayedNewAlbumButtonKey = @"tipsDisplayedNewAlbumButton";
NSString *const kTipsDisplayedCommentsButtonKey = @"tipsDisplayedCommentsButton";
NSString *const kTipsDisplayedPhotoHoleKey = @"tipsDisplayedPhotoHole";
NSString *const kTipsDisplayedPrintsTabKey = @"tipsDisplayedPrintsTab";
NSString *const kWelcomeGroupMessageDisplayedKey = @"welcomeGroupMessageDisplayed";
NSString *const kWelcomeGeneralMessageDisplayedKey = @"welcomeGeneralMessageDisplayed";
NSString *const kWelcomeFriendMessageDisplayedKey = @"welcomeFriendMessageDisplayed";
NSString *const kPendingShareTokenChecked = @"pendingShareTokenChecked";

int const kDefaultSlideshowLength = 3;
BOOL const kDefaultResizeUpload = YES;

typedef enum
{
	NotificationTypeNone = 0,
	NotificationTypeComments = 1 << 0,
	NotificationTypeLike = 1 << 1,
	NotificationTypeUpload = 1 << 2,
	NotificationTypeAlbumJoin = 1 << 3
} NotificationType;

static SettingsModel *settingsModel;

@implementation SettingsModel

@synthesize albumListAnonymousWarningShown;
@synthesize tipDisplayedPhotoHole = _tipDisplayedPhotoHole;

- (id)init
{
	self = [super init];
	if ( self )
	{
		albumListAnonymousWarningShown = NO;
	}

	return self;
}

- (BOOL)boolForKey:(NSString *)keyName defaultValue:(BOOL)defaultBool
{
	if ( [defaultSettings stringForKey:keyName] )
	{
		if ( [[defaultSettings stringForKey:keyName] isEqualToString:@"on"] )
		{
			return YES;
		}
		else
		{
			return NO;
		}
	}
	return defaultBool;
}

- (void)writeBoolValue:(BOOL)boolValue forKey:(NSString *)keyName
{
	NSString *settingValue;
	if ( boolValue )
	{
		settingValue = @"on";
	}
	else
	{
		settingValue = @"off";
	}

	[defaultSettings setObject:settingValue forKey:keyName];
}

- (void)readSettings
{
	defaultSettings = [NSUserDefaults standardUserDefaults];

	// Slideshow transition length
	if ( [defaultSettings integerForKey:kSlideshowLengthKey] )
	{
		slideshowTransitionLength = [defaultSettings integerForKey:kSlideshowLengthKey];
	}
	else
	{
		slideshowTransitionLength = kDefaultSlideshowLength;
	}

	// Resize images on upload
	resizeImagesOnUpload = [self boolForKey:kResizeImagesOnUpload defaultValue:kDefaultResizeUpload];

	// Notifications - enable all by default
	if ( [defaultSettings valueForKey:kEnabledNotificationTypesKey] != nil )
	{
		notificationBitMask = [defaultSettings integerForKey:kEnabledNotificationTypesKey];
	}
	else
	{
		notificationBitMask = NotificationTypeComments + NotificationTypeLike + NotificationTypeUpload + NotificationTypeAlbumJoin;
	}
	commentsNotification = ( notificationBitMask & NotificationTypeComments ) == NotificationTypeComments;
	albumJoinNotification = ( notificationBitMask & NotificationTypeAlbumJoin ) == NotificationTypeAlbumJoin;
	likeNotification = ( notificationBitMask & NotificationTypeLike ) == NotificationTypeLike;
	uploadNotification = ( notificationBitMask & NotificationTypeUpload ) == NotificationTypeUpload;

	pendingShareTokenChecked = [self boolForKey:kPendingShareTokenChecked defaultValue:NO];

	// Tool Tip flags
	tipDisplayedCommentButton = [self boolForKey:kTipsDisplayedCommentsButtonKey defaultValue:NO];
	tipDisplayedNewAlbumButton = [self boolForKey:kTipsDisplayedNewAlbumButtonKey defaultValue:NO];
	tipDisplayedUploadButton = [self boolForKey:kTipsDisplayedUploadButtonKey defaultValue:NO];
	_tipDisplayedPhotoHole = [self boolForKey:kTipsDisplayedPhotoHoleKey defaultValue:NO];
	tipDisplayedPrintsTab = [self boolForKey:kTipsDisplayedPrintsTabKey defaultValue:NO];

	// Welcome screens
	welcomeFriendMessageDisplayed = [self boolForKey:kWelcomeFriendMessageDisplayedKey defaultValue:NO];
	welcomeGeneralMessageDisplayed = [self boolForKey:kWelcomeGeneralMessageDisplayedKey defaultValue:NO];
	welcomeGroupMessageDisplayed = [self boolForKey:kWelcomeGroupMessageDisplayedKey defaultValue:NO];

}

- (void)writeSettings
{
	defaultSettings = [NSUserDefaults standardUserDefaults];

	[defaultSettings setObject:[NSNumber numberWithInt:slideshowTransitionLength] forKey:kSlideshowLengthKey];

	[self writeBoolValue:resizeImagesOnUpload forKey:kResizeImagesOnUpload];

	[defaultSettings setObject:[NSNumber numberWithInt:[self notificationBitMask]] forKey:kEnabledNotificationTypesKey];

	[self writeBoolValue:tipDisplayedCommentButton forKey:kTipsDisplayedCommentsButtonKey];
	[self writeBoolValue:tipDisplayedNewAlbumButton forKey:kTipsDisplayedNewAlbumButtonKey];
	[self writeBoolValue:tipDisplayedUploadButton forKey:kTipsDisplayedUploadButtonKey];
	[self writeBoolValue:_tipDisplayedPhotoHole forKey:kTipsDisplayedPhotoHoleKey];
	[self writeBoolValue:tipDisplayedPrintsTab forKey:kTipsDisplayedPrintsTabKey];

	[self writeBoolValue:welcomeFriendMessageDisplayed forKey:kWelcomeFriendMessageDisplayedKey];
	[self writeBoolValue:welcomeGeneralMessageDisplayed forKey:kWelcomeGeneralMessageDisplayedKey];
	[self writeBoolValue:welcomeGroupMessageDisplayed forKey:kWelcomeGroupMessageDisplayedKey];

	[self writeBoolValue:pendingShareTokenChecked forKey:kPendingShareTokenChecked];

	[defaultSettings synchronize];
}

- (void)updateNotificationBitMask
{
	int tempMask = 0;

	if ( commentsNotification )
	{
		tempMask += NotificationTypeComments;
	}

	if ( albumJoinNotification )
	{
		tempMask += NotificationTypeAlbumJoin;
	}

	if ( likeNotification )
	{
		tempMask += NotificationTypeLike;
	}

	if ( uploadNotification )
	{
		tempMask += NotificationTypeUpload;
	}

	notificationBitMask = tempMask;
}

- (int)notificationBitMask
{
	[self updateNotificationBitMask];

	return notificationBitMask;
}

- (void)updateTipDisplayedBitMask
{
	int tempMask = 0;

	if ( commentsNotification )
	{
		tempMask += NotificationTypeComments;
	}

	if ( albumJoinNotification )
	{
		tempMask += NotificationTypeAlbumJoin;
	}

	if ( likeNotification )
	{
		tempMask += NotificationTypeLike;
	}

	if ( uploadNotification )
	{
		tempMask += NotificationTypeUpload;
	}

	notificationBitMask = tempMask;
}


- (int)slideshowTransitionLength
{
	return slideshowTransitionLength;
}

- (void)setSlideshowTransitionLength:(int)length
{
	slideshowTransitionLength = length;
	[self writeSettings];
}

- (BOOL)uploadNotification
{
	return uploadNotification;
}

- (void)setUploadNotification:(BOOL)on
{
	uploadNotification = on;
	[self writeSettings];
}

- (BOOL)albumJoinNotification
{
	return albumJoinNotification;
}

- (void)setAlbumJoinNotification:(BOOL)on
{
	albumJoinNotification = on;
	[self writeSettings];
}

- (BOOL)likeNotification
{
	return likeNotification;
}

- (void)setLikeNotification:(BOOL)on
{
	likeNotification = on;
	[self writeSettings];
}

- (BOOL)commentsNotification
{
	return commentsNotification;
}

- (void)setCommentsNotification:(BOOL)on
{
	commentsNotification = on;
	[self writeSettings];
}

- (BOOL)resizeImagesOnUpload
{
	return resizeImagesOnUpload;
}

- (void)setResizeImagesOnUpload:(BOOL)on
{
	resizeImagesOnUpload = on;
	[self writeSettings];
}

- (BOOL)tipDisplayedUploadButton
{
	return tipDisplayedUploadButton;
}

- (void)setTipDisplayedUploadButton:(BOOL)on
{
	tipDisplayedUploadButton = on;
	[self writeSettings];
}

- (BOOL)tipDisplayedNewAlbumButton
{
	return tipDisplayedNewAlbumButton;
}

- (void)setTipDisplayedNewAlbumButton:(BOOL)on
{
	tipDisplayedNewAlbumButton = on;
	[self writeSettings];
}

- (BOOL)tipDisplayedCommentsButton
{
	return tipDisplayedCommentButton;
}

- (void)setTipDisplayedCommentsButton:(BOOL)on
{
	tipDisplayedCommentButton = on;
	[self writeSettings];
}

- (BOOL)tipDisplayedPhotoHole
{
	return _tipDisplayedPhotoHole;
}

- (void)setTipDisplayedPhotoHole:(BOOL)on
{
	_tipDisplayedPhotoHole = on;
	[self writeSettings];
}

- (BOOL)tipDisplayedPrintsTab;
{
	return tipDisplayedPrintsTab;
}

- (void)setTipDisplayedPrintsTab:(BOOL)on;
{
	tipDisplayedPrintsTab = on;
	[self writeSettings];
}

- (BOOL)welcomeGroupMessageDisplayed
{
	return welcomeGroupMessageDisplayed;
}

- (void)setWelcomeGroupMessageDisplayed:(BOOL)on
{
	welcomeGroupMessageDisplayed = on;
	[self writeSettings];
}

- (BOOL)welcomeGeneralMessageDisplayed
{
	return welcomeGeneralMessageDisplayed;
}

- (void)setWelcomeGeneralMessageDisplayed:(BOOL)on
{
	welcomeGeneralMessageDisplayed = on;
	[self writeSettings];
}

- (BOOL)welcomeFriendMessageDisplayed
{
	return welcomeFriendMessageDisplayed;
}

- (void)setWelcomeFriendMessageDisplayed:(BOOL)on
{
	welcomeFriendMessageDisplayed = on;
	[self writeSettings];
}

- (BOOL)pendingShareTokenChecked
{
	return pendingShareTokenChecked;
}

- (void)setPendingShareTokenChecked:(BOOL)on
{
	pendingShareTokenChecked = on;
	[self writeSettings];
}


+ (SettingsModel *)settings
{
	if ( !settingsModel )
	{
		settingsModel = [[SettingsModel alloc] init];
	}

	[settingsModel readSettings];

	return settingsModel;
}

- (void)dealloc
{
	[super dealloc];
}


@end
