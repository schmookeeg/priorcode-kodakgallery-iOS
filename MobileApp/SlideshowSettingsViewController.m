//
//  SlideshowSettingsViewController.m
//  MobileApp
//
//  Created by Darron Schall on 8/25/11.
//

#import "SlideshowSettingsViewController.h"
#import "SettingsModel.h"

@interface SlideshowSettingsViewController ()

/**
 Keep track of the path to the previously selected cell so when the user changes a value we
 can toggle the checkmark off.
 */
@property ( nonatomic, retain ) NSIndexPath *indexPathOfPreviousSelection;

@end

@implementation SlideshowSettingsViewController

@synthesize indexPathOfPreviousSelection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		self.tableViewStyle = UITableViewStyleGrouped;
		self.title = @"Slideshow Speed";
		[self.tableView setBackgroundColor:[UIColor colorWithRed:0.949f green:0.949f blue:0.949f alpha:1.0f]];

	}
	return self;
}

- (void)dealloc
{
	self.indexPathOfPreviousSelection = nil;

	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

#pragma mark - TTModelViewController

- (void)createModel
{
	self.dataSource = [TTSectionedDataSource dataSourceWithArrays:

			@"",
			[NSArray arrayWithObjects:
					[TTTableTextItem itemWithText:@"1 Second"],
					[TTTableTextItem itemWithText:@"3 Seconds"],
					[TTTableTextItem itemWithText:@"5 Seconds"],
					/* [TTTableTextItem itemWithText:@"10 Seconds"],*/ nil],
			nil];

}


- (void)didShowModel:(BOOL)firstTime
{

	// De-select all of the cells
	UITableViewCell *cell;

	for ( int i = 0; i < 3/*4*/; i++ )
	{
		cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	// Show the checkmark for the cell that corresponds to th slideshow length
	int slideshowLength = [[SettingsModel settings] slideshowTransitionLength];
	int selectedIndex;
	switch ( slideshowLength )
	{
		case 3:
			selectedIndex = 1;
			break;
		case 5:
			selectedIndex = 2;
			break;
		case 1:
		default:
			selectedIndex = 0;
			break;
			/*case 10:
selectedIndex = 3;
break; */
	}

	self.indexPathOfPreviousSelection = [NSIndexPath indexPathForRow:selectedIndex inSection:0];

	cell = [self.tableView cellForRowAtIndexPath:indexPathOfPreviousSelection];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

/**
 Override so we can determine what data to set on the model based on the selection.
 */
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
	// Bail out if we're trying to select the same row twice
	if ( indexPath.row == self.indexPathOfPreviousSelection.row )
	{
		return;
	}

	// Update the data model with the new value
	int slideshowLength;
	switch ( indexPath.row )
	{
		case 1:
			slideshowLength = 3;
			break;
		case 2:
			slideshowLength = 5;
			break;
			/*case 3:
slideshowLength = 10;
break;*/
		case 0:
		default:
			slideshowLength = 1;
	}
	[[SettingsModel settings] setSlideshowTransitionLength:slideshowLength];

	// Show the checkmark for the new cell
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;

	// Remove the checkmark from the previous cell
	if ( self.indexPathOfPreviousSelection )
	{
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPathOfPreviousSelection];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	// Save the current selection as the new previous value
	self.indexPathOfPreviousSelection = indexPath;
}

@end
