//
//  AddExistingAlbumViewController.h
//  MobileApp
//
//  Created by mikeb on 6/10/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumModelDelegate.h"
#import "AbstractAlbumModel.h"
#import "MBProgressHUD.h"
#import "RootViewController.h"


@interface AddExistingAlbumViewController : RootViewController <UITextFieldDelegate, AlbumModelDelegate, MBProgressHUDDelegate>
{
	IBOutlet UITextField *albumIdInput;
	IBOutlet UIButton *addAlbumButton;
	MBProgressHUD *_hud;
}
- (IBAction)addAlbumButton:(id)sender;

@property ( nonatomic, retain ) AbstractAlbumModel *eventAlbum;

@property ( nonatomic, readonly ) MBProgressHUD *hud;

@end
