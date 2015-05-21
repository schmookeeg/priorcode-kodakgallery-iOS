//
//  TDDatePickerController.m
//
//  Created by Nathan  Reed on 30/09/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import "TDDatePickerController.h"


@implementation TDDatePickerController

@synthesize date;
@synthesize clearVisible;
@synthesize delegate, datePicker;
@synthesize toolBar, cancelButton, flexibleSpace, clearButton, saveButton;

-(void)viewDidLoad
{
    [super viewDidLoad];

    // If there is not an initial date, default to today.
	if ( !self.date )
    {
        self.date = [NSDate date];
    }
    datePicker.date = self.date;

	// we need to set the subview dimensions or it will not always render correctly
	// http://stackoverflow.com/questions/1088163
	for (UIView* subview in datePicker.subviews)
    {
		subview.frame = datePicker.bounds;
	}
        
    if ( clearVisible )
    {
        toolBar.items = [NSArray arrayWithObjects:self.cancelButton, self.flexibleSpace, self.clearButton, self.saveButton, nil];
    }
    else
    {
        toolBar.items = [NSArray arrayWithObjects:self.cancelButton, self.flexibleSpace, self.saveButton, nil];
    }
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark Actions

- (IBAction)saveDateEdit:(id)sender {
	if ( [self.delegate respondsToSelector:@selector(datePickerSetDate:)] )
    {
		[self.delegate datePickerSetDate:self];
	}
}

- (IBAction)clearDateEdit:(id)sender {
	if ( [self.delegate respondsToSelector:@selector(datePickerClearDate:)] )
    {
		[self.delegate datePickerClearDate:self];
	}
}

- (IBAction)cancelDateEdit:(id)sender {
	if ( [self.delegate respondsToSelector:@selector(datePickerCancel:)] )
    {
		[self.delegate datePickerCancel:self];
	}
    else
    {
		// just dismiss the view automatically?
	}
}

#pragma mark -
#pragma mark Memory Management

- (void)viewDidUnload
{
  	self.datePicker = nil;
	self.delegate = nil;
    
    self.toolBar = nil;
    self.cancelButton = nil;
    self.flexibleSpace = nil;
    self.clearButton = nil;
    self.saveButton = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
	self.datePicker = nil;
	self.delegate = nil;
    
    self.toolBar = nil;
    self.cancelButton = nil;
    self.flexibleSpace = nil;
    self.clearButton = nil;
    self.saveButton = nil;
    
    self.date = nil;

    [super dealloc];
}

@end


