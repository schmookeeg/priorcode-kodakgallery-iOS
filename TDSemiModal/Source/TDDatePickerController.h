//
//  TDDatePickerController.h
//
//  Created by Nathan  Reed on 30/09/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import	"TDSemiModal.h"

@class TDDatePickerController;

@protocol TDDatePickerControllerDelegate <NSObject>

@optional
- (void)datePickerSetDate:(TDDatePickerController *)viewController;
- (void)datePickerClearDate:(TDDatePickerController *)viewController;
- (void)datePickerCancel:(TDDatePickerController *)viewController;
@end

@interface TDDatePickerController : TDSemiModalViewController

/**
 This is the initial date to use for the picker.  Setting this value after the picker
 is already loaded will not alter the ui state..
 */
@property (nonatomic, retain) NSDate *date;

/**
 Flag to determine if the clear button should be visible.  Setting this value after the
 picker is already loaded will not alter the ui state.
 */
@property (nonatomic) BOOL clearVisible;

@property (nonatomic, assign) IBOutlet id <TDDatePickerControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIDatePicker* datePicker;

@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *flexibleSpace;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *clearButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)saveDateEdit:(id)sender;
- (IBAction)clearDateEdit:(id)sender;
- (IBAction)cancelDateEdit:(id)sender;

@end