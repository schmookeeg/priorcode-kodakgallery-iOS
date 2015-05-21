//
//  Created by jcampbell on 2/1/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AlbumOptionsActionSheetController.h"
#import "AbstractAlbumModel.h"
#import "AlbumOptionsActionSheetControllerDelegate.h"
#import "AlbumShareActionSheetController.h"
#import "SelectThumbViewController.h"
#import "AnonymousSignInModalAlertView.h"
#import "UserModel.h"


@implementation AlbumOptionsActionSheetController

@synthesize signInAlertView = _signInAlertView;

- (id)initWithDelegate:(id <AlbumOptionsActionSheetControllerDelegate, SelectPhotosViewControllerDelegate>)delegate album:(AbstractAlbumModel *)album
{
	self = [super init];
	if ( self )
	{
		_album = album;
		_delegate = delegate;
	}

	return self;
}


- (void)showOptions
{

	NSMutableArray *otherButtonTitles = [[[NSMutableArray alloc] init] autorelease];


    [otherButtonTitles addObject:NSLocalizedString( @"AlbumOptionsShareAlbum", nil )];

    if ([[_album photoCount] intValue] > 0) {
        [otherButtonTitles addObject:NSLocalizedString( @"AlbumOptionsBuyPrints", nil )];
    }

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What would you like to do with this album?"
															 delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

	for ( NSUInteger i = 0; i < [otherButtonTitles count]; i++ )
	{
		[actionSheet addButtonWithTitle:[otherButtonTitles objectAtIndex:i]];
	}

	actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString( @"Cancel", nil )];

	[actionSheet showInView:[_delegate view]];
	[actionSheet autorelease];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ( buttonIndex == 0 )
	{
		[_delegate.albumShareActionSheetController showOptions];
	}

    else if ([[_album photoCount] intValue] > 0 && buttonIndex == 1) {

		BOOL isLoggedIn = [[UserModel userModel] loggedIn];

		if ( !isLoggedIn )
		{
			self.signInAlertView = [[[AnonymousSignInModalAlertView alloc] initWithAlbum:_album] autorelease];
			[self.signInAlertView setFeatureRequiresLoginMessage];
			[self.signInAlertView show];
		}
		else
		{
			// navigate to buy prints flow
			SelectThumbViewController *viewController = (SelectThumbViewController *) [[TTNavigator navigator] openURLAction:
					[[TTURLAction actionWithURLPath:
							[NSString stringWithFormat:@"tt://selectPhotosInAlbum/%@", _album.albumId]] applyAnimated:NO]];
			viewController.selectPhotosDelegate = _delegate;
		}
	}

	// otherwise cancel
}

- (void)dealloc
{
	[_album release];
	[_delegate release];

	self.signInAlertView = nil;

	[super dealloc];
}

@end
