//
//  Created by darron on 3/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "TDSemiModalViewController.h"
#import "FontInstance.h"

@protocol FontPickerViewControllerDelegate;

@interface FontPickerViewController : TDSemiModalViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
	NSArray *_availableFonts; // Of AvailableFont*
	NSArray *_availableColors; // Of NSString* in the format "rgb(r,g,b)"
	FontInstance *_fontInstance;

	UIPickerView *_pickerView;
	UIToolbar *_toolbar;
	UISegmentedControl *_fontPropertySegments;
	UIBarButtonItem *_flexibleSpace;
	UIBarButtonItem *_doneButton;
}

@property ( nonatomic, assign ) id <FontPickerViewControllerDelegate> delegate;

- (id)initWithAvailableFonts:(NSArray *)availableFonts availableColors:(NSArray *)availableColors fontInstance:(FontInstance *)fontInstance;

@end

@protocol FontPickerViewControllerDelegate <NSObject>

@optional
- (void)picker:(FontPickerViewController *)viewController didConfigureFont:(FontInstance *)fontInstance;

- (void)pickerDidCancel:(FontPickerViewController *)viewController;
@end
