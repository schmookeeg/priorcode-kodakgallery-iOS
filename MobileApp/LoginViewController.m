//
//  LoginViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "AlbumListModel.h"
#import "ShareTokenList.h"

// FIXME See comment in RegisterViewController.  This is some shared code here that we probably want
// to refactor.
@interface LoginViewController ()
- (void)resetInputFields;

- (BOOL)isEmailValid;

- (BOOL)validateEmailField;

- (void)checkSignInState;
@end

@implementation LoginViewController

@synthesize doneButton = _doneButton;
@synthesize returnAlbum = _returnAlbum;
@synthesize signinRequired = _signinRequired;
@synthesize returnToNotifications = _returnToNotifications;

- (id)initWithReturnAlbumId:(NSString *)albumId signinRequired:(NSString *)required;
{
	if ( ( self = [super init] ) )
	{
		self.returnAlbum = [[AlbumListModel albumList] albumFromAlbumId:[NSNumber numberWithDouble:[albumId doubleValue]]];
		self.signinRequired = [required isEqualToString:@"YES"];
	}

	return self;
}

- (id)initWithReturnToNotifications
{
	if ( ( self = [super init] ) )
	{
		self.returnToNotifications = YES;
		self.signinRequired = YES;
	}

	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
	}
	return self;
}

- (void)dealloc
{
	// Release outlets
	[username release];
	[password release];

	[errorField release];
	[signinRequiredLabel release];

	[joinLabel release];
	[joinLink release];

	[_doneButton release];

	[_hud release];

	self.returnAlbum = nil;

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

	//
	// Create the done button that will get placed in the navigationItem
	//
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(doLogin:)];
	doneButton.enabled = NO;
	self.doneButton = doneButton;
	[doneButton release];

	// Configure the user interface properties.  We do this "in one place" in
	// the view controller so that we can use two separate LoginView xib files
	// that don't need to be manually kept in sync regarding ui properties.

	username.placeholder = @"Email Address";
	username.keyboardType = UIKeyboardTypeEmailAddress;
	username.returnKeyType = UIReturnKeyNext;
	username.autocorrectionType = UITextAutocorrectionTypeNo;

	password.placeholder = @"Password";
	password.keyboardType = UIKeyboardTypeDefault;
	password.returnKeyType = UIReturnKeyDone;
	password.secureTextEntry = YES;
	password.autocorrectionType = UITextAutocorrectionTypeNo;

	if ( self.signinRequired )
	{
		[self adjustViewForSigninRequired];
	}

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationController.navigationBarHidden = NO;
	self.navigationItem.title = @"Sign In";
	self.navigationItem.rightBarButtonItem = self.doneButton;

	username.delegate = self;

	[self checkSignInState];

	/*  if (_returnAlbum) {
	  [self showErrorMessage:@"You must login or create an acccount to view this share."];
  }
*/
}

- (void)viewWillDisappear:(BOOL)animated
{
	// Make sure the keyboard disappears
	[username endEditing:YES];
	username.delegate = nil;


	[super viewWillDisappear:animated];
}


- (void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	self.doneButton = nil;

	[joinLabel release];
	joinLabel = nil;

	[joinLink release];
	joinLink = nil;

	[username release];
	username = nil;

	[password release];
	password = nil;

	[errorField release];
	errorField = nil;

	self.returnAlbum = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

#pragma mark MBProgressHUD

- (MBProgressHUD *)hud
{
	return [self hudWithText:@"Signing In..."];
}

- (MBProgressHUD *)hudWithText:(NSString *)text
{
	if ( !_hud )
	{
		_hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		_hud.delegate = self;
		_hud.removeFromSuperViewOnHide = YES;
		[self.navigationController.view addSubview:_hud];

		_hud.labelText = text;
	}
	else
	{
		_hud.labelText = text;
	}

	return _hud;
}

- (void)hudWasHidden
{
	TT_RELEASE_SAFELY(_hud)
}


#pragma mark - IBActions

- (void)adjustViewForSigninRequired
{
	NSString *defaultText = @"The owner of this album requires that you sign-in in order to view it.";
	NSString *notificationText = @"You must sign-in in order to view your notifications.";

	signinRequiredLabel.text = ( _returnToNotifications ) ? notificationText : defaultText;

	signinRequiredLabel.hidden = NO;
	CGFloat yDelta = signinRequiredLabel.bounds.size.height;


	CGPoint errorfieldCenter = errorField.center;
	errorfieldCenter.y += yDelta;
	errorField.center = errorfieldCenter;

	CGPoint usernameCenter = username.center;
	usernameCenter.y += yDelta;
	username.center = usernameCenter;

	CGPoint passwordCenter = password.center;
	passwordCenter.y += yDelta;
	password.center = passwordCenter;

	CGPoint joinLabelCenter = joinLabel.center;
	joinLabelCenter.y += yDelta;
	joinLabel.center = joinLabelCenter;

	CGPoint joinLinkCenter = joinLink.center;
	joinLinkCenter.y += yDelta;
	joinLink.center = joinLinkCenter;

	CGPoint forgetLinkCenter = forgetPasswordLink.center;
	forgetLinkCenter.y += yDelta;
	forgetPasswordLink.center = forgetLinkCenter;


}

- (void)adjustViewForErrorLabel:(BOOL)moveDown
{
	int signMultiplier = moveDown ? 1 : -1;
	CGFloat yDelta = errorField.bounds.size.height * signMultiplier;

	CGPoint usernameCenter = username.center;
	usernameCenter.y += yDelta;

	CGPoint passwordCenter = password.center;
	passwordCenter.y += yDelta;

	CGPoint joinLabelCenter = joinLabel.center;
	joinLabelCenter.y += yDelta;

	CGPoint joinLinkCenter = joinLink.center;
	joinLinkCenter.y += yDelta;

	CGPoint forgetLinkCenter = forgetPasswordLink.center;
	forgetLinkCenter.y += yDelta;
	forgetPasswordLink.center = forgetLinkCenter;

	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^
								{
									username.center = usernameCenter;
									password.center = passwordCenter;

									joinLabel.center = joinLabelCenter;
									joinLink.center = joinLinkCenter;
								}
					 completion:NULL];
}

- (void)showErrorMessage:(NSString *)message
{
	errorField.text = message;

	if ( errorField.hidden )
	{
		[self adjustViewForErrorLabel:YES];
	}
	errorField.hidden = NO;
}

- (void)clearErrorMessage
{
	if ( !errorField.hidden )
	{
		[self adjustViewForErrorLabel:NO];
	}

	errorField.text = @"";
	errorField.hidden = YES;
}

- (BOOL)isEmailValid
{
	NSString *emailValue = username.text;
	return [emailValue length] > 0 && [UserModel validateEmail:emailValue];
}

/*
 Validates the email field and shows the error message if invalid.
 
 Return NO if email is not valid, YES if email is valid.
 */
- (BOOL)validateEmailField
{
	if ( ![self isEmailValid] )
	{
		[self showErrorMessage:NSLocalizedString(@"ErrorMessageEmailInvalid", nil)];

		return NO;
	}
	else
	{
		// We have a valid email address.  If the error message is showing the
		// invalid email address error, then clear it.
		if ( [errorField.text isEqual:NSLocalizedString(@"ErrorMessageEmailInvalid", nil)] )
		{
			[self clearErrorMessage];
		}
	}

	return YES;
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	// STABTWO-1437 - When the email field loses focus, validate email address.
	if ( textField == username )
	{
		if ( ![self validateEmailField] )
		{
			[username becomeFirstResponder];
		}
	}

	[self checkSignInState];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	[self checkSignInState];
	return YES;
}


- (void)checkSignInState
{
	self.doneButton.enabled = ( password.text.length > 0 && username.text.length > 3 && [self validateEmailField] );
}

- (IBAction)doLogin:(id)sender
{
	NSString *emailValue = [username text];
	NSString *passwordValue = [password text];

	[self clearErrorMessage];


	if ( ![self isEmailValid] )
	{
		[self showErrorMessage:NSLocalizedString(@"ErrorMessageEmailInvalid", nil)];
		[username becomeFirstResponder];
		return;
	}
	else if ( [passwordValue length] == 0 )
	{
		[self showErrorMessage:NSLocalizedString(@"ErrorMessagePasswordInvalid", nil)];
		[password becomeFirstResponder];
		return;
	}

	// Make sure the keyboard disappears
	[username resignFirstResponder];
	[password resignFirstResponder];

	[self.hud show:YES];

	// fetch album list before logging in
	AlbumListModel *albumList = [AlbumListModel albumList];

	// don't refresh the list if we have a return album as this is an anonymous login
	if ( [[UserModel userModel] sybaseId] && !_returnAlbum )
	{
		[albumList setDelegate:self];
		[albumList fetch];
	}
	else
	{
		[[UserModel userModel] login:emailValue password:passwordValue delegate:self];
	}

	return;
}

- (IBAction)viewJoinScreen:(id)sender
{
	if ( self.returnAlbum != nil )
	{
		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://register/%@", [self.returnAlbum albumId]]] applyAnimated:YES]];
	}
	else
	{
		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://register"] applyAnimated:YES]];
	}
}

- (IBAction)loginViaFB:(id)sender
{
}

- (IBAction)forgotPassword:(id)sender
{
	NSString *url = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, kServiceForgetPassword];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


- (void)resetInputFields
{
	[self clearErrorMessage];
	username.text = @"";
	password.text = @"";
}

- (void)didModelLoad:(AbstractModel *)model
{
	NSString *usernameVal = [username text];
	NSString *passwordVal = [password text];

	[[UserModel userModel] login:usernameVal password:passwordVal delegate:self];

}

- (void)didModelLoadFail:(AbstractModel *)model withError:(NSError *)error
{
	// continue even if the album list get fails
	NSString *usernameVal = [username text];
	NSString *passwordVal = [password text];

	[[UserModel userModel] login:usernameVal password:passwordVal delegate:self];
}

#pragma mark UserModelDelegate

- (void)didLoginSucceed:(UserModel *)model
{
   	AlbumListModel *albumList = [AlbumListModel albumList];
	[albumList setDelegate:self];
	[albumList joinAllAlbums];

	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Login:Successul" eventName:@"event9"];
}

- (void)didLoginFail:(UserModel *)model error:(NSError *)error
{
	[self.hud hide:YES];

	if ( [[[error userInfo] objectForKey:@"NSLocalizedDescription"] isEqualToString:@"invalidCredentials"] )
	{
		[self showErrorMessage:NSLocalizedString(@"ErrorMessageInvalidCredentials", nil)];
	}
	else
	{
		[self showErrorMessage:NSLocalizedString(@"ErrorMessageServerError", nil)];
	}

	[password setText:@""];
}

#pragma mark AlbumListModelDelegate

- (void)didJoinAllSucceed:(AlbumListModel *)model
{
	[ShareTokenList clear];
	[self.hud hide:YES];

	[self resetInputFields];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAnyChange"];

	[self.navigationController popToRootViewControllerAnimated:NO];

	if ( _returnAlbum )
	{
		NSString *url = [NSString stringWithFormat:@"tt://albumList"];
   		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:url] applyAnimated:YES]];
	}

	if ( _returnToNotifications )
	{
		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://notifications"] applyAnimated:YES]];
	}
}

- (void)didJoinAllFail:(AlbumListModel *)model error:(NSError *)error
{
	[self.hud hide:YES];

	[self showErrorMessage:NSLocalizedString(@"ErrorMessageServerError", nil)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// Check for a valid email
	if ( textField == username )
	{
		//STABTWO-1437 - Validate the email as soon as the user leaves the screen
		if ( [self validateEmailField] )
		{
			// If the email is valid then the password screen can beome the first responder
			[username resignFirstResponder];
			[password becomeFirstResponder];
		}
		else
		{
			// Otherwise, we don't want to close the keyboard
			return NO;
		}
	}
	else if ( textField == password )
	{
		// Auto-press the done button
		[self doLogin:password];
	}
	else
	{
		[textField resignFirstResponder];
	}

	return YES;
}


@end
