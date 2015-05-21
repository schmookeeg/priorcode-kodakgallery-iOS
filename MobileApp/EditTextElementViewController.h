//
//  EditTextElementViewController.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextElement.h"
#import "CharacterLimitWarningBar.h"
#import "FontPickerViewController.h"

@protocol EditTextElementViewControllerDelegate;

@interface EditTextElementViewController : UIViewController <FontPickerViewControllerDelegate, UITextViewDelegate>
{
	/** The text element that we're editing */
	TextElement *_textElement;

	/**
	 * A copy of the text element we're editing.  This lets us update the text property
	 * of the element, which enables us to tap into the text measurement code to power
	 * the character limit warning bar.
	 */
	TextElement *_measuringTextElement;

	UITextView *_textView;

	CharacterLimitWarningBar *_characterLimitWarningBar;
}

@property ( nonatomic, assign ) id <EditTextElementViewControllerDelegate> delegate;

/**
 * Read-only value of a FontInstance that contains all of the edits the user has completed.
 */
@property ( nonatomic, readonly ) FontInstance *fontInstance;

/**
 * Read-only value of the text after the user editing has completed.
 */
@property ( nonatomic, readonly ) NSString *text;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query;

@end

@protocol EditTextElementViewControllerDelegate <NSObject>

@optional

- (void)textElementEditor:(EditTextElementViewController *)editor didFinishEditing:(TextElement *)textElement;

- (void)textElementEditorDidCancelEditing:(EditTextElementViewController *)editor;

@end