//
//  Created by darron on 3/14/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FontPickerViewController.h"
#import "AvailableFont.h"
#import "FontStyle.h"

@implementation FontPickerViewController

@synthesize delegate = _delegate;

#pragma mark init / dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	@throw [NSException exceptionWithName:@"FontPickerViewControllerInitialization"
								   reason:@"Use initWithAvailableFonts:availableColors:fontInstance:"
								 userInfo:nil];
}

- (id)initWithAvailableFonts:(NSArray *)availableFonts availableColors:(NSArray *)availableColors fontInstance:(FontInstance *)fontInstance
{
	self = [super initWithNibName:nil bundle:nil];
	if ( self )
	{
		_availableFonts = [availableFonts copy];
		_availableColors = [availableColors copy];
		_fontInstance = [fontInstance retain];
	}
	return self;
}

- (void)dealloc
{
	[_availableFonts release];
	[_availableColors release];
	[_fontInstance release];

	[_pickerView release];
	[_toolbar release];
	[_fontPropertySegments release];
	[_flexibleSpace release];
	[_doneButton release];

	[super dealloc];
}

#pragma mark View Lifecycle

- (void)loadView
{
	[super loadView];

	_pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake( 0.0, 264.0, 320.0, 216.0 )];
	_pickerView.frame = CGRectMake( 0.0, 264.0, 320.0, 216.0 );
	_pickerView.alpha = 1.000;
	_pickerView.autoresizesSubviews = YES;
	_pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	_pickerView.backgroundColor = [UIColor colorWithWhite:0.333 alpha:1.000];
	_pickerView.clearsContextBeforeDrawing = YES;
	_pickerView.clipsToBounds = NO;
	_pickerView.contentMode = UIViewContentModeScaleToFill;
	_pickerView.contentStretch = CGRectFromString( @"{{0, 0}, {1, 1}}" );
	_pickerView.hidden = NO;
	_pickerView.multipleTouchEnabled = NO;
	_pickerView.opaque = YES;
	_pickerView.showsSelectionIndicator = YES;
	_pickerView.tag = 0;
	_pickerView.userInteractionEnabled = YES;

	_fontPropertySegments = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Font", @"Style", @"Size", @"Color", nil]];
	_fontPropertySegments.selectedSegmentIndex = 0;
	_fontPropertySegments.momentary = NO;
	_fontPropertySegments.segmentedControlStyle = UISegmentedControlStyleBar;
	[_fontPropertySegments addTarget:self action:@selector(handleFontPropertyChange:) forControlEvents:UIControlEventValueChanged];

	_flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	_flexibleSpace.enabled = YES;
	_flexibleSpace.style = UIBarButtonItemStylePlain;
	_flexibleSpace.tag = 0;
	_flexibleSpace.width = 0.000;

	_doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];
	_doneButton.enabled = YES;
	_doneButton.style = UIBarButtonItemStyleDone;
	_doneButton.tag = 0;
	_doneButton.width = 0.000;
	_doneButton.target = self;
	_doneButton.action = @selector(handleDone:);

	_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake( 0.0, 201.0, 320.0, 44.0 )];
	_toolbar.frame = CGRectMake( 0.0, 201.0, 320.0, 44.0 );
	_toolbar.alpha = 1.000;
	_toolbar.autoresizesSubviews = YES;
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
	_toolbar.barStyle = UIBarStyleBlackOpaque;
	_toolbar.clearsContextBeforeDrawing = NO;
	_toolbar.clipsToBounds = NO;
	_toolbar.contentMode = UIViewContentModeScaleToFill;
	_toolbar.contentStretch = CGRectFromString( @"{{0, 0}, {1, 1}}" );
	_toolbar.hidden = NO;
	_toolbar.multipleTouchEnabled = NO;
	_toolbar.opaque = NO;
	_toolbar.tag = 0;
	_toolbar.userInteractionEnabled = YES;

	// TRICKY: Need to wrap the _fontPropertySegments UISegmentedControl in a UIBarButtonItem to place in UIToolbar
	UIBarButtonItem *_fontPropertySegmentsItem = [[UIBarButtonItem alloc] initWithCustomView:_fontPropertySegments];
	_toolbar.items = [NSArray arrayWithObjects:_fontPropertySegmentsItem, _flexibleSpace, _doneButton, nil];
	[_fontPropertySegmentsItem release];

	UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake( 0.0, 0.0, 320.0, 460.0 )];
	coverView.frame = CGRectMake( 0.0, 0.0, 320.0, 460.0 );
	coverView.alpha = 1.000;
	coverView.autoresizesSubviews = YES;
	coverView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	coverView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:1.000];
	coverView.clearsContextBeforeDrawing = YES;
	coverView.clipsToBounds = NO;
	coverView.contentMode = UIViewContentModeScaleToFill;
	coverView.contentStretch = CGRectFromString( @"{{0, 0}, {1, 1}}" );
	coverView.hidden = NO;
	coverView.multipleTouchEnabled = NO;
	coverView.opaque = YES;
	coverView.tag = 0;
	coverView.userInteractionEnabled = YES;

	self.view.frame = CGRectMake( 0.0, 0.0, 320.0, 460.0 );
	self.view.alpha = 1.000;
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	self.view.backgroundColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.000];
	self.view.clearsContextBeforeDrawing = YES;
	self.view.clipsToBounds = NO;
	self.view.contentMode = UIViewContentModeScaleToFill;
	self.view.contentStretch = CGRectMake( 0, 0, 1, 1 );
	self.view.hidden = NO;
	self.view.multipleTouchEnabled = NO;
	self.view.opaque = NO;
	self.view.tag = 0;
	self.view.userInteractionEnabled = YES;

	[self.view addSubview:coverView];
	[self.view addSubview:_pickerView];
	[self.view addSubview:_toolbar];

	self.coverView = coverView;

	[coverView release];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	_pickerView.delegate = self;
	_pickerView.dataSource = self;
	_pickerView.showsSelectionIndicator = YES;    // note this is default to NO

	// we need to set the subview dimensions or it will not always render correctly
	// http://stackoverflow.com/questions/1088163
	for ( UIView *subview in _pickerView.subviews )
	{
		subview.frame = _pickerView.bounds;
	}

	// Pre-select the row in the picker that corresponds to the font.
	NSUInteger row = 0;
	for ( AvailableFont *availableFont in _availableFonts )
	{
		if ( [availableFont.family isEqualToString: _fontInstance.family] )
		{
			break;
		}
		row++;
	}
	[_pickerView selectRow:row inComponent:0 animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

//    [_pickerView selectRow:selectedRow inComponent:0 animated:NO];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_availableFonts count];
}

#pragma mark UIPickerViewDelegate methods


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 45;
}
/*
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 145;
}
*/

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel *label;
	if ( !view )
	{
		label = [[[UILabel alloc] initWithFrame:CGRectMake( 0, 10, 145, 45 )] autorelease];
		label.opaque = NO;
		label.backgroundColor = [UIColor clearColor];
	}
	else if ( [view isKindOfClass:[UILabel class]] )
	{
		label = (UILabel *) view;
	}
	else
	{
		NSLog( @"Cannot convert view: %@", view );
		return nil;
	}

	AvailableFont *availableFont = [_availableFonts objectAtIndex:(NSUInteger) row];
	label.text = availableFont.family;
	label.font = [UIFont fontWithName:[FontInstance uiFontFamilyNameFromFamily:availableFont.family andStyle:FontStyleNormal]
								 size:22];

	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}

#pragma mark Actions

- (void)handleFontPropertyChange:(id)sender
{
	[_pickerView reloadAllComponents];
}

- (void)handleDone:(id)sender
{

	if ( [self.delegate respondsToSelector:@selector(picker:didConfigureFont:)] )
	{
		FontInstance *fontInstance = [[FontInstance alloc] init];

		// Populate fontInstance from the picker selections
		NSUInteger row = (NSUInteger) [_pickerView selectedRowInComponent:0];
		AvailableFont *availableFont = [_availableFonts objectAtIndex:row];
		fontInstance.family = availableFont.family;

		// FIXME: For now, just pass through the style, size, color - eventually we
		// need to get these out of the picker view as well.
		fontInstance.style = _fontInstance.style;
		fontInstance.size = _fontInstance.size;
		fontInstance.color = _fontInstance.color;

		[self.delegate picker:self didConfigureFont:fontInstance];
		[fontInstance release];
	}
}

@end