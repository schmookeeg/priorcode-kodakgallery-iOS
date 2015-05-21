//
//  AddNewAlbumViewController.h
//  MobileApp
//
//  Created by mikeb on 7/11/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "MBProgressHUD.h"
#import <UIKit/UIKit.h>
#import "AbstractAlbumModel.h"
#import "RootViewController.h"
#import "TDPickerViewController.h"
#import "TDDatePickerController.h"
#import "AlbumListModel.h"
#import "AlbumListModelDelegate.h"
#import "AlbumModelDelegate.h"
#import "UIPlaceholderTextView.h"

@interface AddNewAlbumViewController : RootViewController <UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate, AlbumModelDelegate, AlbumListModelDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, TDPickerViewControllerDelegate, TDDatePickerControllerDelegate>
{
	int albumType;
	NSDate *albumDate;

	MBProgressHUD *_hud;
	AlbumListModel *_albumList;

	CGRect keyboardBounds;
}

@property ( nonatomic, retain ) UIBarButtonItem *cancelButton;
@property ( nonatomic, retain ) UIBarButtonItem *doneButton;

@property ( nonatomic, retain ) IBOutlet UIScrollView *scrollView;
@property ( nonatomic, retain ) IBOutlet UITextField *albumNameInput;
@property ( nonatomic, retain ) UITableView *tableView;
@property ( nonatomic, retain ) IBOutlet UIPlaceholderTextView *albumDescriptionInput;

@property ( nonatomic, retain ) NSDateFormatter *dateFormatter;
@property ( nonatomic, retain ) NSNumber *albumId;
@property ( nonatomic, retain ) NSNumber *groupId;


@property ( nonatomic, retain ) AbstractAlbumModel *albumModel;

@property ( nonatomic, readonly ) MBProgressHUD *hud;

- (IBAction)albumNameInputEditingChanged:(UITextField *)textField;

@end
