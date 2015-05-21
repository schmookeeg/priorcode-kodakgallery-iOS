//
//  EditAlbumViewController.h
//  MobileApp
//
//  Created by MAC21 on 12/12/11.
//  Copyright 2011 diaspark India. All rights reserved.
//

#import "MBProgressHUD.h"
#import <UIKit/UIKit.h>
#import "AbstractAlbumModel.h"
#import "RootViewController.h"
#import "AlbumListModel.h"
#import "AlbumListModelDelegate.h"
#import "AlbumModelDelegate.h"
#import "UIPlaceholderTextView.h"
#import "TDPickerViewController.h"
#import "TDDatePickerController.h"

@interface EditAlbumViewController : RootViewController <UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate, AlbumModelDelegate, AlbumListModelDelegate, UITableViewDataSource, UITableViewDelegate, TDPickerViewControllerDelegate, TDDatePickerControllerDelegate> 
{
    int albumType;
  	NSDate *_albumDate;

	MBProgressHUD *_hud;
	AlbumListModel *_albumList;
    
	CGRect keyboardBounds;
    NSNumber *_albumId;
    NSString *_strName;
    NSString *_strDesc;
    UITableView *_tableView;
    
    
}
@property ( nonatomic, retain ) UIBarButtonItem *cancelButton;
@property ( nonatomic, retain ) UIBarButtonItem *doneButton;
@property ( nonatomic, retain ) IBOutlet UITextField *albumNameInput;
@property ( nonatomic, retain ) NSNumber *albumId;
@property ( nonatomic, retain ) NSString *strName;
@property ( nonatomic, retain ) NSString *strDesc;
@property ( nonatomic, retain ) NSDate *albumDate;
@property ( nonatomic, retain ) NSNumber *groupId;
@property ( nonatomic, retain ) IBOutlet UIScrollView *scrollView;
@property ( nonatomic, retain ) UITableView *tableView;
@property ( nonatomic, retain ) IBOutlet UIPlaceholderTextView *albumDescriptionInput;
@property ( nonatomic, retain ) NSDateFormatter *dateFormatter;
@property ( nonatomic, retain ) AbstractAlbumModel *albumModel;
@property ( nonatomic, readonly ) MBProgressHUD *hud;

- (IBAction)albumNameInputEditingChanged:(UITextField *)textField;

@end

