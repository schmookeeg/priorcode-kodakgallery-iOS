//
//  LocationServicesDisabledViewController.m
//  MobileApp
//
//  Created by Dev on 9/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "LocationServicesDisabledViewController.h"
#import "UIColor+Colors.h"
#import <QuartzCore/QuartzCore.h>

@implementation LocationServicesDisabledViewController
@synthesize continueButton, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		// Custom initialization
	}
	return self;
}

- (void)dealloc
{
	[continueButton release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// FIXME: Refactor into a backgroundGradientColors and backgroundGradientLocations property via
// a UIView category, apply to this, LocationServicesDisabled.
- (void)applyGradient
{
	// Initialize the gradient layer
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    
    // Create a bounding area for the empty space at the bottom
    CGRect bounds = self.view.bounds;
    gradientLayer.bounds = self.view.bounds;
    gradientLayer.position = CGPointMake( CGRectGetMidX( bounds ), CGRectGetMidY( bounds ) );
	
    gradientLayer.colors = [UIColor blackViewGradientColors];
    
	[self.view.layer insertSublayer:gradientLayer atIndex:0];
	[gradientLayer release];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	// Do any additional setup after loading the view from its nib.
    [self applyGradient];
}

- (void)viewDidUnload
{
	[self setContinueButton:nil];
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

- (IBAction)didTouchContinue:(id)sender
{
	if ( self.delegate != nil )
	{
		[self.delegate didTouchLocationServicesDisabledWarningExit:sender];
	}
}
@end
