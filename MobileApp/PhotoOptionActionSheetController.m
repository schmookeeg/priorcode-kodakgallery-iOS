//
//  PhotoShareActionSheetController.m
//  MobileApp
//
//  Created by Darron Schall on 11/18/11.
//  Copyright (c) 2011 Universal Mind, Inc. All rights reserved.
//

#import "PhotoOptionActionSheetController.h"
#import "PrintsAddedModalAlertView.h"
#import "CartModel.h"
#import "AnonymousSignInModalAlertView.h"
#import "UserModel.h"

@implementation PhotoOptionActionSheetController

@synthesize album = _album;
@synthesize printsAddedModalAlertView = _printsAddedModalAlertView;
@synthesize signInAlertView = _signInAlertView;

#pragma mark init / dealloc

- (id)initWithDelegate:(id)delegate album:(AbstractAlbumModel *)album photo:(PhotoModel *)photo allowDownload:(BOOL)allowDownload
{
	self = [super initWithDelegate:delegate model:photo metricsContext:@"album/photo"];
	if ( self )
	{
		self.album = album;
		_allowDownload = allowDownload;
	}

    return self;
}

- (void)dealloc
{
    self.signInAlertView = nil;
    [_printsAddedModalAlertView release];
    [super dealloc];
}


#pragma mark - 

- (void)showOptions {
    _smsAvailable = [SMSComposer canSendText];

    NSMutableArray *otherButtonTitles = [[[NSMutableArray alloc] init] autorelease];

    [otherButtonTitles addObject:NSLocalizedString( @"PhotoShareEmail", nil )];

// https://jc.ofoto.com/jira/browse/STABTWO-1987
// Message photo is not available because we don't want to send links in a text message.  Once
// we're able to send the picture itself (without using private APIs), we should re-enable this.
//	if ( _smsAvailable )
//	{
//		[otherButtonTitles addObject:NSLocalizedString( @"PhotoShareTextMessage", nil )];
//	}

    if (_allowDownload) {
        [otherButtonTitles addObject:NSLocalizedString( @"PhotoShareDownload", nil )];
    }
    else {
        [otherButtonTitles addObject:NSLocalizedString( @"PhotoShareDownloadDisabled", nil )];
    }

    [otherButtonTitles addObject:NSLocalizedString( @"PhotoOptionsBuyPrints", nil )];
	[otherButtonTitles addObject:NSLocalizedString( @"PhotoOptionsCreateGift", nil )];

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"PhotoShareActionTitle", nil ) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

    for (NSUInteger i = 0; i < [otherButtonTitles count]; i++) {
        [actionSheet addButtonWithTitle:[otherButtonTitles objectAtIndex:i]];
    }

    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString( @"Cancel", nil )];

    [actionSheet showInView:[_delegate view]];
    [actionSheet autorelease];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self processShareActionAtIndex:buttonIndex withTitle:[actionSheet buttonTitleAtIndex:buttonIndex]];
}

- (void)processShareActionAtIndex:(int)shareIndex withTitle:(NSString *)shareTitle
{
    if (shareTitle == NSLocalizedString( @"PhotoShareEmail", nil ) )
    {
        [self sendEmail];
    }
    else if (shareTitle == NSLocalizedString( @"PhotoShareTextMessage", nil ) )
    {
        [self sendSms];
    }
    else if ( _allowDownload && shareTitle == NSLocalizedString( @"PhotoShareDownload", nil ) )
    {
        [self downloadToPhone];
    }
	else if ( shareTitle == NSLocalizedString( @"PhotoShareDownloadDisabled", nil ) )
	{
		[self showDownloadDisabledAlert];
	}
	else if (shareTitle == NSLocalizedString( @"PhotoOptionsBuyPrints", nil ) )
	{
        [self buyPrints];
    }
	else if ( shareTitle == NSLocalizedString( @"PhotoOptionsCreateGift", nil ) )
	{
		[self createPhotoGift];
	}
}

- (void)showDownloadDisabledAlert; {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Photo Disabled"
                                                        message:@"The owner of this photo has disabled downloads. Photo downloads can be enabled by the owner on the photo's corresponding album page at kodakgallery.com."
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];

    [alertView show];
    [alertView autorelease];
}

- (void)downloadToPhone {
    self.hud.labelText = @"Downloading Photo...";
    [self.hud show:YES];

    // FIXME This should be refactored into a category, this code exists in at least 3 different places
    // https://jc.ofoto.com/jira/browse/STABTWO-2028 - There's an issue with the MBProgressHUD subproject
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

    PhotoModel *photo = (PhotoModel *) self.model;
    [photo downloadFullResolutionPhoto];
    [photo setDelegate:self];
}

#pragma mark PhotoModelDelegate

- (void)photoDownloadDidSucceedWithModel:(PhotoModel *)model {
    [_hud hide:YES];

    // TODO: Should we really show an alert for success?
    [[[[UIAlertView alloc] initWithTitle:@"Download Success"
                                 message:@"Photo downloaded successfully."
                                delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
}

- (void)photoDownloadDidFailWithError:(NSError *)error
{

	[[[[UIAlertView alloc] initWithTitle:@"Download Failed"
								 message:@"Photo download failed. Please try again later."
								delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
}

- (void)buyPrints
{
	if ( ![UserModel userModel].loggedIn )
	{
        self.signInAlertView = [[[AnonymousSignInModalAlertView alloc] initWithAlbum:nil] autorelease];
        [self.signInAlertView setFeatureRequiresLoginMessage];
        [self.signInAlertView show];
    }
	else
	{

        // add stuff to cart
        [[CartModel cartModel] addPhoto:(PhotoModel *) self.model];
		[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Prints:SinglePrintAdded"];

        self.printsAddedModalAlertView = [[[PrintsAddedModalAlertView alloc] initWithPhotoCount:1] autorelease];
        [self.printsAddedModalAlertView show];
    }
}

- (void)createPhotoGift
{
	if ( ![UserModel userModel].loggedIn )
	{
		self.signInAlertView  = [[[AnonymousSignInModalAlertView alloc] initWithAlbum:nil] autorelease];
		[self.signInAlertView  setFeatureRequiresLoginMessage];
		[self.signInAlertView  show];
	}
	else
	{
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Photo Share:Make Magnet"];
        
		// Bypass the photo selection process and proceed directly to the
		// product list view, but go to the shop view first because that's where
        // the product list lives (see PBB-2903)!
        [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://shop"] applyAnimated:NO]];
    
		NSString *url = [NSString stringWithFormat:@"tt://productList/%@/%@", self.album.albumId, ((PhotoModel *)self.model).photoId];
		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:url] applyAnimated:YES]];
	}
}



@end
