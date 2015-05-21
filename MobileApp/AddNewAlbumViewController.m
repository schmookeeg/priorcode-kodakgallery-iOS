//
//  AddNewAlbumViewController.m
//  MobileApp
//
//  Created by Dev on 7/11/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "AddNewAlbumViewController.h"
#import "AlbumListTableViewController.h"

// Private methods
@interface AddNewAlbumViewController ()
- (void)createNewAlbum;

- (void)hideKeyboard;
@end


@implementation AddNewAlbumViewController

@synthesize cancelButton = _cancelButton, doneButton = _doneButton;
@synthesize scrollView = _scrollView;
@synthesize albumNameInput = _albumNameInput, tableView = _tableView, albumDescriptionInput = _albumDescriptionInput;
@synthesize dateFormatter = _dateFormatter;
@synthesize albumModel = _albumModel;
@synthesize albumId, groupId;


#pragma mark Init

- (id)initWithAlbumType:(NSNumber *)type
{
	self = [super init];
	if ( self )
	{
		albumType = [type intValue];
		if ( albumType != kMyAlbumType && albumType != kEventAlbumType )
		{
			[NSException raise:NSInvalidArgumentException format:@"Unsupported album type"];
		}
	}
	return self;
}

#pragma mark Memory Management

- (void)dealloc
{
	[_cancelButton release];
	[_doneButton release];

	[_scrollView release];

	[_albumNameInput release];
	[_tableView release];
	[_albumDescriptionInput release];

	[_dateFormatter release];

	[_hud release];
	[albumDate release];

	[_albumModel release];
	[albumId release];
	[groupId release];

	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.


	// If we're not using the progress hud right now, we can destroy it.
	if ( ![_hud isHidden] )
	{
		[_hud release];
		_hud = nil;
	}
}


#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationController.navigationBarHidden = NO;

	self.navigationItem.title = @"New Album";
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.doneButton;

	self.albumNameInput.text = @"";
	self.albumDescriptionInput.text = @"";

	// Reigster for keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:self.view.window];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:self.view.window];
}


- (void)viewWillDisappear:(BOOL)animated
{
	// Unregister for keyboard notifications while not visible.
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];

	[super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	//
	// Create the bar buttons that will get placed in the navigationItem
	//
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				target:self
																				action:@selector(doneButtonClicked:)];
	self.doneButton = doneButton;
	// Disable the done button until an album name is entered
	self.doneButton.enabled = NO;
	[doneButton release];

	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				  target:self
																				  action:@selector(cancelButtonClicked:)];
	self.cancelButton = cancelButton;
	[cancelButton release];

	//
	// Configure album name input text field
	//
	self.albumNameInput.keyboardType = UIKeyboardTypeAlphabet;
	self.albumNameInput.returnKeyType = UIReturnKeyDefault;

	//
	// Create the table view for the album type and date options
	//
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake( 11, 68, 298, 110 ) style:UITableViewStyleGrouped];
	tableView.bounces = NO;
	tableView.scrollEnabled = NO;
	tableView.sectionHeaderHeight = 5.0;
	tableView.sectionFooterHeight = 4.0;
	tableView.dataSource = self;
	tableView.delegate = self;
	[self.scrollView addSubview:tableView];
	self.tableView = tableView;
	[tableView release];

	//
	// Configure album description input
	//
	self.albumDescriptionInput.placeholder = @"Description (optional)";

	//
	// Configure date formatter
	//
	self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];

	// Create an album date and default it today
	[albumDate release];
	albumDate = [[NSDate date] retain];
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	// Release any retained subviews of the main view (such as outlets).

	self.scrollView = nil;

	self.albumNameInput = nil;
	self.albumDescriptionInput = nil;

	// Release anything that can be re-created in viewdidLoad

	[self.tableView removeFromSuperview];
	self.tableView = nil;


	self.doneButton = nil;
	self.cancelButton = nil;

	self.dateFormatter = nil;

	[albumDate release];
	albumDate = nil;

	[_hud release];
	_hud = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//return TTIsSupportedOrientation( interfaceOrientation );
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

#pragma mark MBProgressHUD

- (MBProgressHUD *)hud
{
	if ( !_hud )
	{
		_hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		_hud.delegate = self;
		_hud.removeFromSuperViewOnHide = YES;
		[self.navigationController.view addSubview:_hud];
	}

	return _hud;
}

- (void)hudWasHidden
{
	// Free up memory when the hud goes away by release it safely (which prevents
	// a dual-release in dealloc as well)
	TT_RELEASE_SAFELY(_hud)
}

- (NSString *)albumTypeAsString
{
	if ( albumType == kMyAlbumType )
	{
		return @"My Album";
	}
	else // albumType == kEventAlbumType
	{
		return @"Group Album";
	}
}


#pragma mark UITableView data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellStyleValue1CellID = @"CellStyleValue1CellID";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellStyleValue1CellID];
	if ( cell == nil )
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellStyleValue1CellID] autorelease];
	}

	if ( indexPath.section == 0 )
	{
		cell.textLabel.text = @"Album Type";
		cell.detailTextLabel.text = [self albumTypeAsString];
	}
	else
	{
		cell.textLabel.text = @"Date";
		cell.detailTextLabel.text = [self.dateFormatter stringFromDate:albumDate];
	}

	return cell;
}

#pragma mark UITableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( indexPath.section == 0 )
	{
		// Create and show the picker view for the album types
		TDPickerViewController *albumPickerView = [[TDPickerViewController alloc]
				initWithNibName:@"TDPickerViewController"
						 bundle:nil];
		albumPickerView.delegate = self;
		albumPickerView.dataSource = self;
		albumPickerView.pickerViewTitles = [NSArray arrayWithObjects:@"My Album", @"Group Album", nil];
		albumPickerView.selectedRow = ( albumType == kMyAlbumType ) ? 0 : 1;

		[self presentSemiModalViewController:albumPickerView];
		[albumPickerView release];
	}
	else
	{
		// Create and show the date picker
		TDDatePickerController *datePickerView = [[TDDatePickerController alloc]
				initWithNibName:@"TDDatePickerController"
						 bundle:nil];
		datePickerView.delegate = self;
		datePickerView.date = albumDate;

		[self presentSemiModalViewController:datePickerView];
		[datePickerView release];
	}

	[tableView deselectRowAtIndexPath:indexPath animated:NO];

	[self hideKeyboard];
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 2;
}

#pragma mark TDPickerViewControllerDelegate methods

- (void)picker:(TDPickerViewController *)viewController didSelectRow:(NSInteger)row
{
	albumType = row == 0 ? kMyAlbumType : kEventAlbumType;

	// Update the cell text to be the new date value
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.detailTextLabel.text = [self albumTypeAsString];

	[self dismissSemiModalViewController:viewController];
}

- (void)pickerDidCancel:(TDPickerViewController *)viewController
{
	[self dismissSemiModalViewController:viewController];
}

#pragma mark TDDatePickerControllerDelegate methods

- (void)datePickerSetDate:(TDDatePickerController *)viewController
{
	// Save the date value
	[albumDate release];
	albumDate = [viewController.datePicker.date retain];

	// Update the cell text to be the new date value
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.detailTextLabel.text = [self.dateFormatter stringFromDate:albumDate];

	[self dismissSemiModalViewController:viewController];
}

- (void)datePickerClearDate:(TDDatePickerController *)viewController
{
	[self dismissSemiModalViewController:viewController];
}

- (void)datePickerCancel:(TDDatePickerController *)viewController
{
	[self dismissSemiModalViewController:viewController];
}


- (void)scrollViewToCenterOfScreen:(UIView *)theView
{
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	CGFloat availableHeight = applicationFrame.size.height - keyboardBounds.size.height;	// Remove area covered by keyboard

	CGFloat y = theView.center.y - availableHeight / 2.0;
	if ( y < 0 )
	{
		y = 0;
	}
	self.scrollView.contentSize = CGSizeMake( applicationFrame.size.width, applicationFrame.size.height + keyboardBounds.size.height );
	[self.scrollView setContentOffset:CGPointMake( 0, y ) animated:YES];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self scrollViewToCenterOfScreen:textField];
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[self scrollViewToCenterOfScreen:textView];
}

#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardBoundsValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
	[keyboardBoundsValue getValue:&keyboardBounds];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];

	self.scrollView.contentSize = CGSizeMake( applicationFrame.size.width, applicationFrame.size.height );
	[self.scrollView setContentOffset:CGPointMake( 0, 0 ) animated:YES];
}

#pragma mark Actions

- (void)hideKeyboard
{
	[self.albumNameInput resignFirstResponder];
	[self.albumDescriptionInput resignFirstResponder];
}

- (IBAction)albumNameInputEditingChanged:(UITextField *)textField
{
	self.doneButton.enabled = ( self.albumNameInput.text.length > 0 );
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];

	return YES;
}

- (IBAction)cancelButtonClicked:(id)sender
{
	[[TTNavigator navigator].visibleViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneButtonClicked:(id)sender
{
	[self createNewAlbum];
}

#pragma mark Create Album and Delegate

- (void)createNewAlbum
{
	[self hideKeyboard];

	self.hud.labelText = @"Creating...";
	[self.hud show:YES];

	// Create the right concrete implementation based on album type value of input selector
	Class albumModelClass = [AbstractAlbumModel albumClassFromType:albumType];
	AbstractAlbumModel *albumModel = [[albumModelClass alloc] init];

	// Collect data form the UI to populate the album model
	albumModel.name = self.albumNameInput.text;
	albumModel.albumDescription = self.albumDescriptionInput.text;
	albumModel.userEditedDate = albumDate;

	// Create the album and get notified of results
	[albumModel setDelegate:self];
	[albumModel create];

	// Save the property and release the local variable
	self.albumModel = albumModel;
	[albumModel release];
}

- (void)notifyAlbumList
{
	UIViewController *vc = [TTNavigator navigator].visibleViewController;
	UINavigationController *nc = [vc navigationController];
	NSArray *viewControllerStack = [nc viewControllers];

	for ( id viewController in viewControllerStack )
	{
		if ( [viewController isKindOfClass:[AlbumListTableViewController class]] )
		{
			[(AlbumListTableViewController *) viewController setLastRefreshDate:nil];
		}
	}
}

- (void)didModelLoad:(AbstractModel *)model;
{
	// This fires when the albumList has been successfully loaded and now contains the newly created album.
	// At this point we can exit the create screen and take the user to the desired view.

	[_albumList setDelegate:nil];

	[self.hud hide:YES];

	[model setDelegate:nil];

	if ( albumType == kMyAlbumType )
	{
		[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Create Album:My Album" eventName:@"event71"];
	}
	else
	{
		[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Create Album:Group Album" eventName:@"event72"];
	}



	// FIXME We probably want to use the same dismiss modal call here that cancelButtonClicked: uses
	// [[[[TTNavigator navigator] visibleViewController] navigationController] popViewControllerAnimated:YES];
	[[TTNavigator navigator].visibleViewController dismissModalViewControllerAnimated:NO];
	[self notifyAlbumList];

	[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://album/%@", self.albumId]]];
}

- (void)didCreateSucceed:(AbstractAlbumModel *)model albumId:(NSNumber *)newAlbumId
{
	self.albumId = newAlbumId;

	// Upon creating an album we have to reload the album list prior to taking the user to the thumbanil view as that view
	// expects the album being displayed to exist in the album list.
	_albumList = [AlbumListModel albumList];
	[_albumList setDelegate:self];
	[_albumList fetch];
}

- (void)didCreateFail:(AbstractAlbumModel *)model error:(NSError *)error
{
	[self.hud hide:YES];

	[[[[UIAlertView alloc] initWithTitle:@"Creation Failed"
								 message:@"Album creation failed. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
}

@end
