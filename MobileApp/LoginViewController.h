//
//  LoginViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
#import "UserModelDelegate.h"
#import "AlbumListModelDelegate.h"
#import "AbstractAlbumModel.h"
#import "RootViewController.h"
#import "MBProgressHUD.h"

@interface LoginViewController : RootViewController <UITextFieldDelegate, UserModelDelegate, AlbumListModelDelegate, MBProgressHUDDelegate>
{


	IBOutlet UITextField *password;
	IBOutlet UITextField *username;

	IBOutlet UILabel *errorField;
	IBOutlet UILabel *signinRequiredLabel;

	IBOutlet UILabel *joinLabel;
	IBOutlet UIButton *joinLink;
	IBOutlet UIButton *forgetPasswordLink;

	MBProgressHUD *_hud;

	AbstractAlbumModel *_returnAlbum;
	BOOL _returnToNotifications;
	BOOL _signinRequired;
}

@property ( nonatomic, retain ) UIBarButtonItem *doneButton;

@property ( nonatomic, readonly ) MBProgressHUD *hud;

@property ( nonatomic, retain ) AbstractAlbumModel *returnAlbum;

@property ( nonatomic ) BOOL signinRequired;
@property ( nonatomic ) BOOL returnToNotifications;

- (id)initWithReturnAlbumId:(NSString *)albumId signinRequired:(NSString *)required;

- (id)initWithReturnToNotifications;

- (void)adjustViewForSigninRequired;

- (IBAction)doLogin:(id)sender;

- (IBAction)viewJoinScreen:(id)sender;

- (IBAction)loginViaFB:(id)sender;

- (IBAction)forgotPassword:(id)sender;

- (MBProgressHUD *)hudWithText:(NSString *)text;

@end
