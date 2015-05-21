//
//  EditTextElementViewController.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "EditTextElementViewController.h"
#import "TDSemiModal.h"

@interface EditTextElementViewController ()
- (void)updateBackgroundColor;
- (void)updateCharacterLimitWaringDisplay;
@end

@implementation EditTextElementViewController

@synthesize delegate = _delegate;
@synthesize fontInstance = _fontInstance;

#pragma mark init / dealloc

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
	self = [super initWithNibName:nil bundle:nil];
	if ( self )
	{
		self.title = @"Edit Text";

		// TRICKY Pull the url from the dictionary query that was supplied with the
		// action that brought us here.
		_textElement = [query objectForKey:@"textElement"];
		[_textElement retain];

		_measuringTextElement = [_textElement mutableCopy];
		[_measuringTextElement addObserver:self forKeyPath:@"characterLimitReached" options:NSKeyValueObservingOptionNew context:NULL];

		// If the user changes the font via the styles button, then we will get a
		// new font instance back from the editor (via picker:didConfigureFont:).
		// However, if the user does not change the font at all, we need a value
		// for the _fontInstance, so we just default it to whatever the current
		// font is for the text element.
		_fontInstance = [_textElement.currentFont retain];

		self.delegate = [query objectForKey:@"delegate"];
	}

	return self;
}

- (void)dealloc
{
	[_textElement release];
	[_measuringTextElement removeObserver:self forKeyPath:@"characterLimitReached"];
	[_measuringTextElement release];
	[_textView release];

	[_characterLimitWarningBar release];

	[_fontInstance release];

	[super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
	[super loadView];

	_textView = [[UITextView alloc] initWithFrame:CGRectMake( 0, 40, 320, 240 )];
	_textView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_textView];

	_characterLimitWarningBar = [[CharacterLimitWarningBar alloc] initWithFrame:CGRectMake( 0, 0, 320, 40 )];
	[self.view addSubview:_characterLimitWarningBar];

	[self updateCharacterLimitWaringDisplay];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Styles"
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(handleChangeStyles:)] autorelease];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleDone:)] autorelease];

	// Configure initial values for the text display
	_textView.text = _textElement.text;
	_textView.textColor = _textElement.uiColorFromCurrentFont;
	_textView.font = [UIFont fontWithName:_fontInstance.uiFontFamilyName size:[_fontInstance.size floatValue]];
	_textView.delegate = self;
	[self updateBackgroundColor];

	// Automatically focus the text area
	[_textView becomeFirstResponder];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	[_textView release];
	_textView = nil;

	[_characterLimitWarningBar release];
	_characterLimitWarningBar = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

/**
 * Examines the brightness of the text color and updates the background color to
 * have sufficient contrast.
 */
- (void)updateBackgroundColor
{
	UIColor *color = _textElement.uiColorFromCurrentFont;
	const CGFloat *componentColors = CGColorGetComponents( color.CGColor );

	// Brightness equation taken from http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
	CGFloat colorBrightness = ( ( componentColors[0] * 299 ) + ( componentColors[1] * 587 ) + ( componentColors[2] * 114 ) ) / 1000;
	if ( colorBrightness < 0.5 )
	{
		// Color is dark, use a light background
		self.view.backgroundColor = [UIColor whiteColor];
	}
	else
	{
		// Color is light, use a dark background
		self.view.backgroundColor = [UIColor blackColor];
	}
}

- (NSString *)text
{
	return _textView.text;
}

#pragma mark Actions

- (void)handleChangeStyles:(id)sender
{
	// Make sure that the keyboard closes so we can see the picker view.
	[_textView resignFirstResponder];

	// Create and show the picker view for the album types
	FontPickerViewController *fontPickerView = [[FontPickerViewController alloc]
			initWithAvailableFonts:_textElement.availableFonts
				   availableColors:_textElement.availableColors
					  fontInstance:_fontInstance];
	fontPickerView.delegate = self;

	[self presentSemiModalViewController:fontPickerView];
	[fontPickerView release];
}

- (void)handleDone:(id)sender
{
	if ( [_delegate respondsToSelector:@selector(textElementEditor:didFinishEditing:)] )
	{
		[_delegate textElementEditor:self didFinishEditing:_textElement];
	}

	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Shake-to-cancel support

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self resignFirstResponder];
	[super viewWillDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	if ( motion == UIEventSubtypeMotionShake )
	{
		if ( [_delegate respondsToSelector:@selector(textElementEditorDidCancelEditing:)] )
		{
			[_delegate textElementEditorDidCancelEditing:self];
		}

		[self dismissModalViewControllerAnimated:YES];
	}
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
	// Triggers KVO update to [self updateCharacterLimitWarningDisplay]
	_measuringTextElement.text = textView.text;
}

#pragma mark FontPickerViewControllerDelegate methods

- (void)picker:(FontPickerViewController *)viewController didConfigureFont:(FontInstance *)fontInstance
{
	// Save the font instance so it can be returned to the delegate
	[fontInstance retain];
	[_fontInstance release];
	_fontInstance = fontInstance;

	// Update the text in the editor display
	_textView.font = [UIFont fontWithName:_fontInstance.uiFontFamilyName size:[_fontInstance.size floatValue]];

	// Pass the font through to the measure text element and trigger the measurement
	// calculation again.
	// Triggers KVO update to [self updateCharacterLimitWarningDisplay]
	_measuringTextElement.currentFont = _fontInstance;

	[self dismissSemiModalViewController:viewController];

	// Send keyboard focus back to the text view
	[_textView becomeFirstResponder];
}

- (void)pickerDidCancel:(FontPickerViewController *)viewController
{
	[self dismissSemiModalViewController:viewController];

	// Send keyboard focus back to the text view
	[_textView becomeFirstResponder];
}

#pragma mark - KVO


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( object == _measuringTextElement && [keyPath isEqualToString:@"characterLimitReached"] )
	{
		[self updateCharacterLimitWaringDisplay];
	}
}

- (void)updateCharacterLimitWaringDisplay
{
	_characterLimitWarningBar.hidden = ![_measuringTextElement characterLimitReached];
}

@end
