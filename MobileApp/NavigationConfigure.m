//
//  NavigationConfigure.m
//  MobileApp
//
//  Created by Jon Campbell on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NavigationConfigure.h"
#import "Three20/Three20.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "DocumentDisplayViewController.h"
#import "UploadViewController.h"
#import "UploadEventAlbumListTableViewController.h"
#import "AlbumListTableViewController.h"
#import "ThumbViewController.h"
#import "AddExistingAlbumViewController.h"
#import "AddNewAlbumViewController.h"
#import "PhotoCommentsListTableViewController.h"
#import "NotificationsViewController.h"
#import "SettingsViewController.h"
#import "SlideshowSettingsViewController.h"
#import "PushSettingsViewController.h"
#import "WelcomeMessageViewController.h"
#import "EditAlbumViewController.h"
#import "LocationViewController.h"
#import "ManagedWebViewController.h"
#import "SelectThumbViewController.h"
#import "CartManagedWebViewController.h"
#import "TabBarController.h"
#import "SelectAlbumViewController.h"
#import "ShopViewController.h"
#import "ProductListViewController.h"
#import "ProductDetailViewController.h"
#import "SPMCartManagedWebViewController.h"

@interface NavigationConfigure (Private)

+ (void)initializeNavigationMap:(TTURLMap*)map;

@end

@implementation NavigationConfigure

+ (void)initializeNavigation:(UIWindow*)window
{
    TTNavigator *navigator = [TTNavigator navigator];
	navigator.window = window;

    // Configure the navigation URLs
	TTURLMap *map = navigator.URLMap;
    [self initializeNavigationMap:map];
    
    // Start the application by opening up the Tab Bar
    [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://tabBar"]];
    
	// Show the general welcome page for first-time users
	if ( ![[SettingsModel settings] welcomeGeneralMessageDisplayed] )
	{
		[[SettingsModel settings] setWelcomeGeneralMessageDisplayed:YES];
		[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://welcome/display"]];
	}
}

+ (void)initializeNavigationMap:(TTURLMap*)map
{
    [map from:@"tt://tabBar" toViewController:[TabBarController class]];
    
	[map from:@"tt://login" toSharedViewController:[LoginViewController class]];
	[map from:@"tt://login/(initWithReturnAlbumId:)/(signinRequired:)" toSharedViewController:[LoginViewController class]];
	[map from:@"tt://login/returnToNotifications" toSharedViewController:[LoginViewController class] selector:@selector(initWithReturnToNotifications)];
	[map from:@"tt://register" toSharedViewController:[RegisterViewController class]];
	[map from:@"tt://register/(initWithReturnAlbumId:)" toSharedViewController:[RegisterViewController class]];
	[map from:@"tt://register/displayTerms" toViewController:[DocumentDisplayViewController class]];
	[map from:@"tt://upload" toViewController:[UploadViewController class]];
	[map from:@"tt://upload/select" toViewController:[UploadEventAlbumListTableViewController class]];
	[map from:@"tt://upload/(initWithAlbumId:)" toViewController:[UploadViewController class]];
	[map from:@"tt://albumList" toViewController:[AlbumListTableViewController class]];
	[map from:@"tt://albumList/(initWithAlbumType:)" toViewController:[AlbumListTableViewController class]];
	[map from:@"tt://album/(initWithAlbumId:)" toViewController:[ThumbViewController class]];
	[map from:@"tt://album/photo/(initPhotoWithAlbumId:)" toViewController:[ThumbViewController class]];
	[map from:@"tt://album/photo/(initPhotoWithAlbumId:)/(photoId:)" toViewController:[ThumbViewController class]];
	[map from:@"tt://addExistingAlbum" toSharedViewController:[AddExistingAlbumViewController class]];
	[map from:@"tt://addNewAlbum/(initWithAlbumType:)" toModalViewController:[AddNewAlbumViewController class]];
	[map from:@"tt://photoComments/(initWithPhotoId)" toViewController:[PhotoCommentsListTableViewController class]];
	[map from:@"tt://photoComments/post/(initWithPhotoIdPost)" toViewController:[PhotoCommentsListTableViewController class]];
	[map from:@"tt://notifications" toModalViewController:[NotificationsViewController class]];
	[map from:@"tt://settings" toViewController:[SettingsViewController class]];
	[map from:@"tt://settings/slideshowSpeed" toViewController:[SlideshowSettingsViewController class]];
	[map from:@"tt://settings/push" toSharedViewController:[PushSettingsViewController class]];
	[map from:@"tt://settings/displayEULA/(initWithEULA:)" toViewController:[DocumentDisplayViewController class]];
	[map from:@"tt://settings/displayCredits/(initWithCredits:)" toViewController:[DocumentDisplayViewController class]];
	[map from:@"tt://settings/displayDocument" toViewController:[DocumentDisplayViewController class]];
	[map from:@"tt://welcome/display" toModalViewController:[WelcomeMessageViewController class]];
    [map from:@"tt://editAlbum/(initWithAlbum:)" toModalViewController:[EditAlbumViewController class]];

    [map from:@"tt://buyPrints/selectLocation" toModalViewController:[LocationViewController class]];
    [map from:@"tt://buyPrints/web/cart" toSharedViewController:[CartManagedWebViewController class]];

	[map from:@"tt://selectAlbum" toViewController:[SelectAlbumViewController class]];
	[map from:@"tt://selectAlbumModal" toModalViewController:[SelectAlbumViewController class]];

	// Present the select photos as a view that is pushed onto the navigation stack.  This is the next logical
	// screen after the "tt://selectAlbum" url.
    [map from:@"tt://selectPhotosInAlbumNav/(initWithAlbumId:)" toViewController:[SelectThumbViewController class]];

	// Present the select photos as a modal dialog given a certain album id.  This replaces the back button
	// with a Cancel button to act in the modal context.
	  [map from:@"tt://selectPhotosInAlbum/(initWithAlbumId:)" toModalViewController:[SelectThumbViewController class]];


    [map from:@"tt://shop" toSharedViewController:[ShopViewController class]];
    
    [map from:@"tt://productList/(initWithAlbumId:)/(photoId:)" toSharedViewController:[ProductListViewController class]];
    
    // This URL expects an NSDictionary query applied with "project" and "dataSource", keys defined.
    [map from:@"tt://productDetail" toViewController:[ProductDetailViewController class]];
    
    // This URL expects an NSDictionary query applied with "imageElement" and "delegate" keys defined.
    [map from:@"tt://editImageElement" toModalViewController:[EditImageElementViewController class]];
    
    // This URL expects an NSDictionary query applied with a "textElement" key defined.
    [map from:@"tt://editTextElement" toModalViewController:[EditTextElementViewController class]];

	[map from:@"tt://spm/cart" toModalViewController:[SPMCartManagedWebViewController class]];
}

@end
