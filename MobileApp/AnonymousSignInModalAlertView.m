//
//  AnonymousSignInModalAlertView.m
//  MobileApp
//
//  Created by Jon Campbell on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnonymousSignInModalAlertView.h"
#import "AlbumListModel.h"


@implementation AnonymousSignInModalAlertView

@synthesize alertView = _alertView, album = _album, alertTitle = _alertTitle, alertMessage = _alertMessage;
@synthesize cancelSelector;
@synthesize target;

- (void)setFullExperienceMessage {
    self.alertTitle = @"Currently Not Signed In";
    self.alertMessage = @"Sign in, or create a free account, for the full-featured experience.";
    self.cancelTitle = @"Remain as Guest";
}

- (void)setFeatureRequiresLoginMessage {
    self.alertTitle = @"Please Sign In";
    self.alertMessage = @"You need to be signed in to your account to use this feature.";
    self.cancelTitle = @"Cancel";
}

- (id)init
{
	self = [super initWithNibName:nil bundle:nil];
	if ( self )
	{
		// Custom initialization
        [self setFullExperienceMessage];
    }
	return self;
}

- (id)initWithAlbum:(AbstractAlbumModel *)album {
    self = [self init];
    	if ( self )
    	{
          self.album = album;
        }
    	return self;
}

- (id)initWithTarget:(id)aTarget selector:(SEL)aSelector {
	self = [self init];
	if ( self )
	{
        target = [aTarget retain];
        cancelSelector = aSelector;
    }
	return self;
}





- (void)show
{
	_alertView.title = _alertTitle;
	_alertView.message = _alertMessage;
    [_alertView show];
}

- (NSString *)cancelTitle {
    return [self.alertView buttonTitleAtIndex:self.alertView.cancelButtonIndex];

}

- (void)setCancelTitle:(NSString *)aCancelTitle {
    self.alertView = [[[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:aCancelTitle otherButtonTitles:@"Sign In", @"Create a Free Account", nil] autorelease];
}


- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( _album != nil )
	{
		// if this isn't in the list, put it there so the album page can pull it out and use it
		if ( [[AlbumListModel albumList] albumFromAlbumId:_album.albumId] == nil )
		{
			[[AlbumListModel albumList] setAlbums:[NSArray arrayWithObjects:_album, nil]];
		}
	}


	if ( buttonIndex == 1 )
	{
		[[[[TTNavigator navigator] visibleViewController] navigationController] popToRootViewControllerAnimated:NO];
		if ( _album != nil )
		{
			[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://login/%@/NO", _album.albumId]] applyAnimated:YES]];
		}
		else
		{
			[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://login"] applyAnimated:YES]];
		}

		[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Home:New User:Login"];
	}
	else if ( buttonIndex == 2 )
	{
		[[[[TTNavigator navigator] visibleViewController] navigationController] popToRootViewControllerAnimated:NO];
		if ( _album != nil )
		{
			[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://register/%@", _album.albumId]] applyAnimated:YES]];
		}
		else
		{
			[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://register"] applyAnimated:YES]];
			[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Home:New User:Join"];
		}
	}
	else if ( buttonIndex == 0 )
	{
		if ( _album != nil && _album.allowAnon )
		{
			[[[[TTNavigator navigator] visibleViewController] navigationController] popToRootViewControllerAnimated:NO];
			[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://album/%@", _album.albumId]]];
		}

        if (target && self.cancelSelector) {
            [target performSelector:self.cancelSelector];
        } else {
            [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Home:New User:Anonymous"];
        }
	}
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

- (void)dealloc
{
	self.alertView = nil;
	self.album = nil;

	[_alertTitle release];
	[_alertMessage release];

    [target release];
    [super dealloc];
}

@end
