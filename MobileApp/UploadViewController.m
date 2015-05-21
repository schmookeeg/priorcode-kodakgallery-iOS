//
//  UploadViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadViewController.h"
#import "AlbumListModel.h"
#import "UploadModel.h"
#import "ELCAlbumPickerController.h"
#import "AlbumPhotoSource.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import "AlbumListTableViewController.h"
#import "ThumbViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface UploadViewController ()
/**
 Dismiss the upload progress view and remove it from memory.
 */
- (void)destroyUploadProgressView;

/**
 Create a "Loading" MBProgressHUD and display it on screen.
 */
- (void)createAndShowModelLoadingProgressView;
@end


@implementation UploadViewController
@synthesize albumId = _albumId;

- (id)initWithAlbumId:(NSString *)albumId
{

	self = [super init];

	_uploadInProgress = NO;
	_currentView = [self view];

	self.title = @"Upload to album";

	if ( self )
	{

		if ( !uploadModel )
		{
			uploadModel = [[UploadModel alloc] init];
			[uploadModel setDelegate:self];
		}

		_needsToShowPicker = YES;
	}

	[self setAlbumId:albumId];

	// STABTWO-1507 - Create an "empty" button to serve as a dummy replacement for the back button
	// which would normally appear in this view.  The user can hit the regular back button at the exact
	// moment we display an action sheet and that seems to "hang" this view.
	UIView *dummyUIView = [[UIView alloc] init];
	_dummyBackButton = [[UIBarButtonItem alloc] initWithCustomView:dummyUIView];
	[dummyUIView release];

	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		// Custom initialization
	}

	return self;
}

- (void)createAndShowModelLoadingProgressView
{
	// Remove previous is exists
	[modelLoadingProgressView hide:YES];
	[modelLoadingProgressView release];

	// Create new
	modelLoadingProgressView = [[MBProgressHUD alloc] initWithView:self.view];
	modelLoadingProgressView.labelText = @"Loading";
	modelLoadingProgressView.removeFromSuperViewOnHide = YES;

	// Show
	[self.navigationController.view addSubview:modelLoadingProgressView];
	[modelLoadingProgressView show:YES];
}

- (void)beginSelectAlbumFlow
{
	[self selectAlbum];

	[modelLoadingProgressView hide:YES];
	[modelLoadingProgressView release];
	modelLoadingProgressView = nil;

	[self checkLocationEnabledAndDisplayPicker];
}

- (void)showPhotoSources
{
	if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
	{

		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a photo source"
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil otherButtonTitles:@"Use the camera", @"Existing photos", nil];

		[actionSheet showInView:_currentView];
		[actionSheet release];

	}
	else
	{
		// Device does not have a camera - just allow selection of existing images
		[self checkLocationEnabledAndDisplayPicker];
	}

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( buttonIndex == 0 )
	{
		[self showCamera];

	}
	else if ( buttonIndex == 1 )
	{
		[self checkLocationEnabledAndDisplayPicker];

	}
	else
	{
		[self exitUploadView];
	}
}

- (void)showCamera
{
	UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
	cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
	cameraUI.allowsEditing = NO;
	cameraUI.delegate = self;
	cameraUI.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];
	[self presentModalViewController:cameraUI animated:YES];
	[cameraUI release];
}

// User hit cancel in camera UI
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[picker release];
	[self exitUploadView];
}

- (int)mapImageOrientationToExif:(UIImageOrientation)orientation
{
	// Orientation mapping courtesy of: http://stackoverflow.com/questions/6699330/how-to-save-photo-with-exifgps-and-orientation-on-iphone
	switch ( orientation )
	{
		case UIImageOrientationUp :
			return 1;

		case UIImageOrientationDown :
			return 3;

		case UIImageOrientationLeft :
			return 8;

		case UIImageOrientationRight :
			return 6;

		default:
			return 1;
	}
}

// User captured a photo in the camera UI
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{

	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	NSDictionary *imageMetaData;
	UIImage *originalImage;
	NSMutableArray *uploadURLArray = [NSMutableArray array];

	// Handle a still image capture
	if ( CFStringCompare( (CFStringRef) mediaType, kUTTypeImage, 0 ) == kCFCompareEqualTo )
	{

		_uploadInProgress = YES;

		originalImage = (UIImage *) [info objectForKey:
				UIImagePickerControllerOriginalImage];

		imageMetaData = (NSDictionary *) [info objectForKey:UIImagePickerControllerMediaMetadata];
		NSMutableDictionary *metaDict = [[NSMutableDictionary dictionaryWithDictionary:imageMetaData] retain];
		int orient = [self mapImageOrientationToExif:originalImage.imageOrientation];
		[metaDict setObject:[NSNumber numberWithInt:orient]
					 forKey:(NSString *) kCGImagePropertyOrientation];


		// If portrait images we need to rotate them as imaging-services does not respect the EXIF orientation attributes
		if ( orient == 6 || orient == 8 )
		{
			// Have to rotate image - for some reason this won't happen unless we swap the EXIF X/Y Dimensions manually
			// Thanks Apple for not documenting this :(
			NSMutableDictionary *exifDict = [NSMutableDictionary dictionaryWithDictionary:[metaDict objectForKey:@"{Exif}"]];
			NSNumber *xDim = [exifDict objectForKey:@"PixelXDimension"];
			NSNumber *yDim = [exifDict objectForKey:@"PixelYDimension"];
			[exifDict setObject:yDim forKey:@"PixelXDimension"];
			[exifDict setObject:xDim forKey:@"PixelYDimension"];
			[metaDict setObject:exifDict forKey:@"{Exif}"];
		}


		ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
		[al writeImageToSavedPhotosAlbum:[originalImage CGImage]
								metadata:metaDict
						 completionBlock:^( NSURL *assetURL, NSError *error )
										 {
											 if ( error == nil )
											 {
												 [uploadURLArray insertObject:assetURL atIndex:0];
												 [self startUpload:uploadURLArray];
											 }
											 else
											 {
												 NSLog( @"Failure to save image to asset library" );
												 [self exitUploadView];
											 }
										 }];
		[al release];
		[metaDict autorelease];

	}

	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[picker release];

}


- (void)selectAlbum
{
	AlbumListModel *list = [AlbumListModel albumList];

	[uploadModel setAlbum:[list albumFromAlbumId:[NSNumber numberWithDouble:[_albumId doubleValue]]]];
}


- (void)showPicker
{

	ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
	[albumController setParent:elcPicker];
	[elcPicker setDelegate:self];

	[self presentModalViewController:elcPicker animated:NO];
	[elcPicker release];
	[albumController release];
}

- (void)showLocationServicesDisabled
{
	locationServicesDisabledViewController = [[LocationServicesDisabledViewController alloc] init];
	locationServicesDisabledViewController.delegate = self;
	[self presentModalViewController:locationServicesDisabledViewController animated:YES];
}

- (void)didTouchLocationServicesDisabledWarningExit:(id)sender
{
	[self dismissModalViewControllerAnimated:NO];

	TT_RELEASE_SAFELY(locationServicesDisabledViewController)

	[self exitUploadView];
}


- (void)checkLocationEnabledAndDisplayPicker
{

	// The first time the user attempts to select an photo for upload via the AssetLibrary they will be prompted to enable
	// location services for our app.  This code presents an instructional view prior to the user receiving that location services
	// alert box so they know why we are prompting for access.
	if ( [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined )
	{
		// They've never been prompted with the location question - show the instructional dialog first
		firstTimeLocationWarningViewController = [[FirstTimeLocationWarningViewController alloc] init];
		firstTimeLocationWarningViewController.delegate = self;
		[self presentModalViewController:firstTimeLocationWarningViewController animated:YES];

	}
	else if ( [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized )
	{
		// Location services is disabled - user has to go to settings and re-enable it.
		[self showLocationServicesDisabled];

	}
	else
	{
		[self checkForAccessAndDisplayPicker];
	}
}

- (void)didTouchContinue:(id)sender
{
	[self dismissModalViewControllerAnimated:NO];

	TT_RELEASE_SAFELY(firstTimeLocationWarningViewController)

	[self checkForAccessAndDisplayPicker];
}


- (void)checkForAccessAndDisplayPicker
{
	// We need to first test that the user has enabled location services for this app by making a null call to the assetLibrary
	// If that succeeds we show the real ELCAlbumPicker which will pull the AssetLibrary contents in on a background thread.
	ALAssetsLibraryAssetForURLResultBlock successBlock = ^( ALAsset *asset )
	{
		[self performSelector:@selector(showPicker) withObject:nil afterDelay:0.1];
	};

	// Group Enumerator Failure Block
	ALAssetsLibraryAccessFailureBlock failureBlock = ^( NSError *error )
	{
		NSLog( @"A problem occured %@", [error description] );

		if ( [error code] == -3310 )
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Accessing Photos" message:@"Unable to access photo library. Please open the \"Photos\" application and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		else if ( [error code] == -3311 )
		{
			[self showLocationServicesDisabled];

		}
		else
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@", [error description]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	};

	// this nil assetForUrl forces the location dialog up if it's the first run, before running things in the background
	ALAssetsLibrary *libraryTemp = [[[ALAssetsLibrary alloc] init] autorelease];
	[libraryTemp assetForURL:nil resultBlock:successBlock failureBlock:failureBlock];
}


- (void)showUploadAlbumSelector
{
	// Pop this view off because the Album Selector will eventually push this view back onto the stack
	[[self navigationController] popViewControllerAnimated:NO];
	[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://upload/select"] applyAnimated:YES]];;
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{

	[self dismissModalViewControllerAnimated:YES];

	NSMutableArray *array = [NSMutableArray array];

	for ( NSDictionary *dict in info )
	{
		NSURL *assetUrl = [dict objectForKey:@"UIImagePickerControllerReferenceURL"];

		[array insertObject:assetUrl atIndex:[array count]];

	}

	if ( [array count] == 0 )
	{
		[self exitUploadView];
	}
	else
	{
		[self startUpload:array];
	}
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
	[[self navigationController] popViewControllerAnimated:YES];
	//[[self navigationController] popToRootViewControllerAnimated:YES];
}

#pragma mark Upload

- (void)destroyUploadProgressView
{
	[uploadProgressView dismissWithClickedButtonIndex:-1 animated:YES];

	TT_RELEASE_SAFELY(uploadProgressView)

	[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAlbumList" object:self userInfo:nil];
}

- (void)startUpload:(NSArray *)uploads
{
	NSLog( @"starting upload" );

	// Clear out a previous dialog if it exists
//    [self destroyUploadProgressView];

	// Clear the new upload progress dialog
	NSString *message = [NSString stringWithFormat:@"1 of %d photos", [uploads count]];
	uploadProgressView = [[UIAlertView alloc] initWithTitle:@"Uploading...\n\n\n" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];

	// Create an activity indicator and adjust it's frame to place it below the title and above the message
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	indicator.frame = CGRectMake( 121.0f, 45.0f, 37.0f, 37.0f );
	[indicator startAnimating];
	[uploadProgressView addSubview:indicator];
	[indicator release];

	[uploadProgressView show];

	self.navigationController.navigationBarHidden = YES;

	_uploadInProgress = YES;
	[uploadModel uploadImageQueue:uploads];

	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Upload:Started" eventName:@"event12"];

	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)showUploadFailureCount:(UploadModel *)model
{
	int total = [[model uploadQueue] count];

	if ( total == 0 )
	{
		return;
	}

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Some uploads failed"
													message:[NSString stringWithFormat:@"%d of %d photos failed to upload.", _failedUploads, total]
												   delegate:nil cancelButtonTitle:@"Ok"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)uploadFileComplete:(UploadModel *)model uploadIndex:(NSInteger)uploadIndex
{
	int current = uploadIndex + 2;
	int total = [[model uploadQueue] count];

	if ( current > total )
	{
		return;
	}

	uploadProgressView.message = [NSString stringWithFormat:@"%d of %d photos", current, total];
}

- (void)uploadAllComplete:(UploadModel *)model
{
	NSLog( @"upload complete!" );


	[AlbumPhotoSource setAlbumDirty:YES];

	[self destroyUploadProgressView];

	if ( _failedUploads > 0 )
	{
		[self showUploadFailureCount:model];
	}

	_uploadInProgress = NO;

	// Pop all nav controllers off the stack so when the person hits the "back" button in the album view they go back to the main menu
	[self exitUploadView];

	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Upload:Completed" eventName:@"event13"];

	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)uploadFailure:(UploadModel *)model uploadIndex:(NSInteger)uploadIndex response:(RKResponse *)response error:(NSError *)error
{
	_failedUploads += 1;
	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Upload:Failed" eventName:@"event75"];
}


- (void)notifyAlbumList
{
	// Invalidate the lastUpdated flag in the AlbumListTableViewController to force it to refresh
	NSArray *viewControllerStack = [[self navigationController] viewControllers];
	for ( id viewController in viewControllerStack )
	{
		if ( [uploadModel.album isMyAlbum] && [viewController isKindOfClass:[ThumbViewController class]] )
		{
			ThumbViewController *thumbViewController = (ThumbViewController *) viewController;
			// scroll to bottom after upload for my albums
			[thumbViewController setScrollToBottom:YES];
		}


		if ( [viewController isKindOfClass:[AlbumListTableViewController class]] )
		{
			AlbumListTableViewController *albumListViewController = (AlbumListTableViewController *) viewController;
			[albumListViewController setLastRefreshDate:nil];


		}
	}
}


- (void)exitUploadView
{
	[self notifyAlbumList];
	[[self navigationController] popViewControllerAnimated:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( buttonIndex == [alertView cancelButtonIndex] )
	{
		NSLog( @"upload canceled!" );

		[uploadModel cancelUploadQueue];

		// TODO Do we show a dialog with a X of Y photos uploaded successfully?

		_uploadInProgress = NO;
		[self exitUploadView];

		[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Upload:Cancelled" eventName:@"event61"];
	}

	TT_RELEASE_SAFELY(uploadProgressView)
}



#pragma mark Memory Management

- (void)dealloc
{
	[uploadModel release];
	uploadModel = nil;
	[_albumId release];
	_albumId = nil;

	[_dummyBackButton release];

	[modelLoadingProgressView release];

	[locationServicesDisabledViewController release];
	[firstTimeLocationWarningViewController release];

	// It's likely that uploadProgressView is already nil
	// here via destroyUploadProgressView, but just in case...
	[uploadProgressView release];

	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if ( !_albumId )
	{
		// They haven't picked an album to upload into - this will occur if upload is chosen off the main menu
		[self showUploadAlbumSelector];
	}
	else
	{
		if ( _uploadInProgress )
		{
			// If we're already uploading just wait for completion
			return;
		}
		else
		{
		}
		/*
        if ([uploadModel album]) {
            [self showUploadAlbumSelector];
        }
        else
        {
            // We're waiting for the model to load, show the
            // temporary loading dialog
            [self createAndShowModelLoadingProgressView];
        }
		 */

	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[self navigationItem] setLeftBarButtonItem:_dummyBackButton];

	if ( _needsToShowPicker )
	{
		[self createAndShowModelLoadingProgressView];
		[self beginSelectAlbumFlow];
		_needsToShowPicker = NO;
	}
}


- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

@end
