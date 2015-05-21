//
//  TDPickerViewController.m
//
//

#import "TDPickerViewController.h"


@implementation TDPickerViewController

@synthesize selectedRow;
@synthesize delegate, dataSource;
@synthesize pickerView;
@synthesize toolBar, cancelButton, flexibleSpace, saveButton;
@synthesize pickerViewTitles;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    pickerView.delegate = self;
    pickerView.dataSource = self.dataSource;
    pickerView.showsSelectionIndicator = YES;    // note this is default to NO
    
    // we need to set the subview dimensions or it will not always render correctly
	// http://stackoverflow.com/questions/1088163
	for ( UIView* subview in pickerView.subviews )
    {
		subview.frame = pickerView.bounds;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [pickerView selectRow:selectedRow inComponent:0 animated:NO];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerViewTitles objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Don't need to do anything here actually becuase we can just
    // get the selected row via pickerView selectedRowInComponent:
}

#pragma mark -
#pragma mark Actions

- (IBAction)saveSelection:(id)sender
{
	if ( [self.delegate respondsToSelector:@selector(picker:didSelectRow:)] )
    {
		[self.delegate picker:self didSelectRow:[pickerView selectedRowInComponent:0]];
	}
}

- (IBAction)cancelSelection:(id)sender
{
	if ( [self.delegate respondsToSelector:@selector(pickerDidCancel:)] )
    {
		[self.delegate pickerDidCancel:self];
	}
}

#pragma mark -
#pragma mark Memory Management

- (void)viewDidUnload
{
  	self.pickerView = nil;
    
    self.toolBar = nil;
    self.cancelButton = nil;
    self.flexibleSpace = nil;
    self.saveButton = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
	self.pickerView = nil;
    
    self.toolBar = nil;
    self.cancelButton = nil;
    self.flexibleSpace = nil;
    self.saveButton = nil;
    
    self.pickerViewTitles = nil;

    [super dealloc];
}


@end


