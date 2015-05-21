//
//  AlbumShareActionSheetController.m
//  MobileApp
//
//  Created by Darron Schall on 11/18/11.
//  Copyright (c) 2011 Universal Mind, Inc. All rights reserved.
//

#import "AlbumShareActionSheetController.h"

@implementation AlbumShareActionSheetController

- (id)initWithDelegate:(id)delegate album:(AbstractAlbumModel *)album
{
	self = [super initWithDelegate:delegate model:album metricsContext:@"album"];
	if ( self )
	{

	}

	return self;
}

- (void)dealloc
{
    [_shareTitle release];
    _shareTitle = nil;
    
	[super dealloc];
}

#pragma mark - 

- (void)showOptions
{
	_smsAvailable = [SMSComposer canSendText];

    NSMutableArray *otherButtonTitles = [[[NSMutableArray alloc] init] autorelease];
    
	[otherButtonTitles addObject:NSLocalizedString( @"AlbumShareEmail", nil )];
    
	if ( _smsAvailable )
	{
		[otherButtonTitles addObject:NSLocalizedString( @"AlbumShareTextMessage", nil )];
	}
    
    [otherButtonTitles addObject:NSLocalizedString( @"AlbumShareFacebook", nil )];
    [otherButtonTitles addObject:NSLocalizedString( @"AlbumShareMoreOptions", nil )];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"AlbumShareActionTitle", nil )
												  delegate:self cancelButtonTitle:nil
									destructiveButtonTitle:nil otherButtonTitles:nil];
	
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
	AbstractAlbumModel *album = (AbstractAlbumModel *) self.model;
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    // If the album already has a share token then we can process the action right away
	if ( [album shareToken] != nil )
	{
		[self processShareActionAtIndex:buttonIndex withTitle:buttonTitle];
	}
    // We need to create a share token for the album first, but we only have to do
    // that if the buttonIndex was not the cancel button.
	else if ( buttonIndex != actionSheet.cancelButtonIndex )
	{
		_shareIndex = buttonIndex;

        assert( _shareTitle == nil );
        _shareTitle = [buttonTitle retain];

		self.hud.labelText = @"Loading...";

		[self.hud show:YES];
		[album setDelegate:self];
		[album createShare];
	}
}

- (void)processShareActionAtIndex:(int)shareIndex withTitle:(NSString *)shareTitle;
{
	if ( shareTitle == NSLocalizedString( @"AlbumShareEmail", nil ) )
	{
		[self sendEmail];
	}
	else if ( shareTitle == NSLocalizedString( @"AlbumShareTextMessage", nil ) )
	{
		[self sendSms];
	}
	else if ( shareTitle == NSLocalizedString( @"AlbumShareFacebook", nil ) )
	{
		[self sendFacebook];
	}
	else if ( shareTitle == NSLocalizedString( @"AlbumShareMoreOptions", nil ) )
	{
		[self sendAddThis];
	}
}

#pragma mark AlbumModelDelegate

- (void)didCreateShareSucceed:(AbstractAlbumModel *)model shareToken:(NSString *)shareToken
{
	[_hud hide:YES];

	[self processShareActionAtIndex:_shareIndex withTitle:_shareTitle];
    
    // Don't need the share title anymore
    [_shareTitle release];
    _shareTitle = nil;
}

- (void)didCreateShareFail:(AbstractAlbumModel *)model error:(NSError *)error
{
	[_hud hide:YES];

	NSLog( @"Create share for album failed" );
    
    // Don't need the share title anymore
    [_shareTitle release];
    _shareTitle = nil;

	// TODO: Better flow here?  Try again?  Release delegate?
}


@end
