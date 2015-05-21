//
//  RegisterViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"
#import "UserModel.h"
#import "AlbumListModel.h"
#import "ShareTokenList.h"
#import "AlbumListTableViewController.h"

// FIXME There is a lot of shared code beteween RegisterViewController and LoginViewController
// that can probably be refactored into a separate category or a common base class
//   - email input field checking
//   - form validate on done button
//   - error message and view adjustment

@interface RegisterViewController ()
- (void)resetInputFields;

- (BOOL)isEmailValid;

- (BOOL)validateEmailField;

- (void)checkRegisterState;
@end

@implementation RegisterViewController

@synthesize signUpButton = _signUpButton;
@synthesize returnAlbum = _returnAlbum;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
	}
	return self;
}

- (id)initWithReturnAlbumId:(NSString *)albumId
{
	self = [super init];
	if ( self )
	{
		self.returnAlbum = [[AlbumListModel albumList] albumFromAlbumId:[NSNumber numberWithDouble:[albumId doubleValue]]];
	}

	return self;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.

	// If we're not using the progress hud right now, we can destroy it.
	if ( ![_hud isHidden] )
	{
		[_hud release];
		_hud = nil;
	}
}

- (void)dealloc
{
	[scrollView release];

	[firstName release];
	[email release];
	[password release];
	[confirmPassword release];

	[offersLabel release];
	[offersSwitch release];

	[termsLabel release];
	[termsLink release];

	[errorField release];

	[_signUpButton release];

	[_hud release];

	[_returnAlbum release];

	[super dealloc];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	firstName.autocorrectionType = UITextAutocorrectionTypeNo;
	email.autocorrectionType = UITextAutocorrectionTypeNo;

	self.navigationController.navigationBarHidden = NO;
	self.navigationItem.title = @"Create Account";
	self.navigationItem.rightBarButtonItem = self.signUpButton;

	// Reigster for keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:self.view.window];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:self.view.window];

	[self checkRegisterState];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// Unregister for keyboard notifications while not visible.
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];

	[super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Do any additional setup after loading the view from its nib.

	//
	// Create the done button that will get placed in the navigationItem
	//
	UIBarButtonItem *signUpButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign up"
																	 style:UIBarButtonItemStyleDone
																	target:self
																	action:@selector(doneButtonClicked:)];
	signUpButton.enabled = NO;
	self.signUpButton = signUpButton;
	[signUpButton release];


}

- (void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	self.signUpButton = nil;

	TT_RELEASE_SAFELY( scrollView );

	TT_RELEASE_SAFELY( firstName )
	TT_RELEASE_SAFELY( email )
	TT_RELEASE_SAFELY( password )
	TT_RELEASE_SAFELY( confirmPassword )

	TT_RELEASE_SAFELY( offersLabel )
	TT_RELEASE_SAFELY( offersSwitch )

	TT_RELEASE_SAFELY( termsLabel )
	TT_RELEASE_SAFELY( termsLink )

	TT_RELEASE_SAFELY( errorField )
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

#pragma mark MBProgressHUD

- (MBProgressHUD *)hud
{
	if ( !_hud )
	{
		_hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		_hud.delegate = self;
		_hud.removeFromSuperViewOnHide = YES;
		[self.navigationController.view addSubview:_hud];
	}

	return _hud;
}

- (void)hudWasHidden
{
	TT_RELEASE_SAFELY(_hud)
}

- (void)scrollViewToCenterOfScreen:(UIView *)theView
{
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	CGFloat availableHeight = applicationFrame.size.height - keyboardBounds.size.height;	// Remove area covered by keyboard

	CGFloat y = theView.center.y - availableHeight / 2.0;
	if ( y < 0 )
	{
		y = 0;
	}
	scrollView.contentSize = CGSizeMake( applicationFrame.size.width, applicationFrame.size.height + keyboardBounds.size.height );
	[scrollView setContentOffset:CGPointMake( 0, y ) animated:YES];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self scrollViewToCenterOfScreen:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	// STABTWO-1437 - When the email field loses focus, validate email address.
	if ( textField == email )
	{
		if ( ![self validateEmailField] )
		{
			[email becomeFirstResponder];
		}
	}

	[self checkRegisterState];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	[self checkRegisterState];
	return YES;
}

- (void)checkRegisterState
{
	self.signUpButton.enabled = ( password.text.length > 0 && confirmPassword.text.length > 0
			&& firstName.text.length > 0 && email.text.length > 3 && [self validateEmailField] );
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[self scrollViewToCenterOfScreen:textView];
}

#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
	[keyboardBoundsValue getValue:&keyboardBounds];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];

	scrollView.contentSize = CGSizeMake( applicationFrame.size.width, applicationFrame.size.height );
	[scrollView setContentOffset:CGPointMake( 0, 0 ) animated:YES];
}

# pragma mark - Actions

- (void)adjustViewForErrorLabel:(BOOL)moveDown
{
	int signMultiplier = moveDown ? 1 : -1;
	CGFloat yDelta = errorField.bounds.size.height * signMultiplier;

	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^
								{

									// Loop through all of the children in the scroll view
									for ( UIView *subview in [scrollView subviews] )
									{
										// Skip past the error field
										if ( subview == errorField )
										{
											continue;
										}

										CGPoint center = subview.center;
										center.y += yDelta;
										subview.center = center;
									}

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
	NSString *emailValue = email.text;
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

- (void)doneButtonClicked:(id)sender
{
	[self clearErrorMessage];

	NSString *emailValue = email.text;
	NSString *passwordValue = password.text;
	NSString *confirmPasswordValue = confirmPassword.text;
	NSString *firstNameValue = firstName.text;
	NSString *emailNotificationValue = offersSwitch.on ? @"true" : @"false";

	// Make sure the keyboard disappears
	[firstName resignFirstResponder];
	[email resignFirstResponder];
	[password resignFirstResponder];
	[confirmPassword resignFirstResponder];

	if ( [firstNameValue length] == 0 )
	{
		[self showErrorMessage:NSLocalizedString(@"ErrorMessageFirstNameInvalid", nil)];
		[firstName becomeFirstResponder];
		return;
	}
	else if ( ![self isEmailValid] )
	{
		[self showErrorMessage:NSLocalizedString(@"ErrorMessageEmailInvalid", nil)];
		[email becomeFirstResponder];
		return;
	}
	else if ( [passwordValue length] == 0 )
	{
		[self showErrorMessage:NSLocalizedString(@"ErrorMessagePasswordInvalid", nil)];
		// Commented out because focusing the password field shifts the screen
		// and causes the error message to not be in view
		//[password becomeFirstResponder];
		return;
	}
	else if ( [passwordValue length] < 6 )
	{
		[self showErrorMessage:NSLocalizedString(@"ErrorMessagePasswordTooShort", nil)];
		// Commented out because focusing the password field shifts the screen
		// and causes the error message to not be in view
		//[password becomeFirstResponder];
		return;
	}
	else if ( ![passwordValue isEqualToString:confirmPasswordValue] )
	{
		[self showErrorMessage:NSLocalizedString(@"ErrorMessageConfirmPasswordInvalid", nil)];
		// Commented out because focusing the confirm password field shifts the screen
		// and causes the error message to not be in view
		//[confirmPassword becomeFirstResponder];
		return;
	}

	self.hud.labelText = @"Signing Up...";
	[self.hud show:YES];

	NSDictionary *parameters = [NSDictionary dictionaryWithKeysAndObjects:@"email", emailValue,
																		  @"password", passwordValue,
																		  @"passwordConfirm", confirmPasswordValue,
																		  @"firstName", firstNameValue,
																		  @"emailNotification", emailNotificationValue,
																		  nil];
	[[UserModel userModel] create:parameters delegate:self];
}

- (IBAction)openTermsOfService:(id)sender
{
	// TRICKY Because we need to pass a url string as a parameter, we use a dictionary to set the url
	// for the "url" key that can be looked up using the magic initWithNavigatorURL:query: that
	// the mapped view controller implements.
	NSString *termsUrl = [NSString stringWithFormat:@"%@%@", kRestKitBaseUrl, @"/gallery/mobile/app/termsOfService.jsp"];
	NSString *termsTitle = @"Terms of Service";
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:termsUrl, @"url", termsTitle, @"title", nil];

	TTURLAction *actionUrl = [[[TTURLAction actionWithURLPath:@"tt://register/displayTerms"] applyAnimated:YES] applyQuery:dictionary];
	[[TTNavigator navigator] openURLAction:actionUrl];
}

- (void)resetInputFields
{
	[self clearErrorMessage];
	email.text = @"";
	password.text = @"";
	confirmPassword.text = @"";
	firstName.text = @"";
	offersSwitch.on = YES;
}

#pragma mark - UserModelDelegate

- (void)didRegisterSucceed:(UserModel *)model
{
	AlbumListModel *albumList = [AlbumListModel albumList];
	[albumList setDelegate:self];
	[albumList joinAllAlbums];

	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Join Successful" eventName:@"event10"];
}

- (void)didRegisterFail:(UserModel *)model error:(NSError *)error
{
	[self.hud hide:YES];

	NSString *message = [[error userInfo] objectForKey:@"message"];
	if ( [error code] == 2 )
	{
		if ( [message isEqualToString:@"duplicateUser"] )
		{
			[self showErrorMessage:NSLocalizedString(@"ErrorMessageEmailAlreadyExists", nil)];
		}
		else
		{
			[self showErrorMessage:[NSString stringWithFormat:@"Register error: %@", message]];
		}
	}
	else
	{
		[self showErrorMessage:@"Server error. Please try again later."];
	}

	password.text = @"";
	confirmPassword.text = @"";
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
		NSString *url = [NSString stringWithFormat:@"tt://album/%@", [_returnAlbum albumId]];
		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:url] applyAnimated:YES]];
	}
}

- (void)didJoinAllFail:(AlbumListModel *)model error:(NSError *)error
{
	[self.hud hide:YES];

	[self showErrorMessage:@"There was a server error. Please try again later."];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ( textField == firstName )
	{
		[email becomeFirstResponder];
	}
	else if ( textField == email )
	{
		//STABTWO-1437 - Validate the email as soon as the user leaves the screen
		if ( [self validateEmailField] )
		{
			// If the email is valid then the password screen can beome the first responder
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
		[confirmPassword becomeFirstResponder];
	}

	[textField resignFirstResponder];

	return YES;
}

@end
