//
//  RegisterViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModelDelegate.h"
#import "RootViewController.h"
#import "AlbumListModelDelegate.h"
#import "AbstractAlbumModel.h"
#import "MBProgressHUD.h"

@interface RegisterViewController : RootViewController <UserModelDelegate, UITextFieldDelegate, AlbumListModelDelegate, MBProgressHUDDelegate>
{
	IBOutlet UIScrollView *scrollView;

	IBOutlet UITextField *email;
	IBOutlet UITextField *password;
	IBOutlet UITextField *confirmPassword;
	IBOutlet UITextField *firstName;

	IBOutlet UITextField *offersLabel;
	IBOutlet UISwitch *offersSwitch;

	// Terms of service labels
	IBOutlet UITextView *termsLabel;
	IBOutlet UIButton *termsLink;

	IBOutlet UILabel *errorField;

	MBProgressHUD *_hud;

	AbstractAlbumModel *_returnAlbum;

	CGRect keyboardBounds;
}

@property ( nonatomic, retain ) UIBarButtonItem *signUpButton;

@property ( nonatomic, readonly ) MBProgressHUD *hud;

@property ( nonatomic, retain ) AbstractAlbumModel *returnAlbum;


- (id)initWithReturnAlbumId:(NSString *)albumId;

- (IBAction)openTermsOfService:(id)sender;

@end
