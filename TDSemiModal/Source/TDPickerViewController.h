//
//  TDPickerViewController.h
//

#import <UIKit/UIKit.h>
#import	"TDSemiModal.h"

@class TDPickerViewController;

@protocol TDPickerViewControllerDelegate <NSObject>

@optional
- (void)picker:(TDPickerViewController *)viewController didSelectRow:(NSInteger)row;
- (void)pickerDidCancel:(TDPickerViewController *)viewController;
@end

@interface TDPickerViewController : TDSemiModalViewController <UIPickerViewDelegate>
{
    
}

/**
 Initial row to select.  Setting this value after the
 picker is already loaded will not alter the ui state.
 */
@property (nonatomic, assign) int selectedRow;

@property (nonatomic, assign) id <TDPickerViewControllerDelegate> delegate;
@property (nonatomic, assign) id <UIPickerViewDataSource> dataSource;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;

@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *flexibleSpace;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

@property (nonatomic, retain) NSArray *pickerViewTitles;

- (IBAction)saveSelection:(id)sender;
- (IBAction)cancelSelection:(id)sender;

@end