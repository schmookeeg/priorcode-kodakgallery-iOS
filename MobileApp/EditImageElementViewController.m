//
//  EditImageElementViewController.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "EditImageElementViewController.h"
#import "MathUtil.h"

@interface EditImageElementViewController ()

- (void)applyBackgroundGradient;

- (void)updateDisplayForCropChange;

- (void)updateSelectedFilter;

@end

@implementation EditImageElementViewController

@synthesize delegate = _delegate;

#pragma mark init / dealloc

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
	self = [super initWithNibName:nil bundle:nil];
	if ( self )
	{
		self.title = @"Edit Photo";

		// TRICKY Pull the url from the dictionary query that was supplied with the
		// action that brought us here.
		_imageElement = [query objectForKey:@"imageElement"];
		[_imageElement retain];

		self.delegate = [query objectForKey:@"delegate"];
	}

	return self;
}

- (void)dealloc
{
	[_imageElement release];

	[zoomCropEditView removeObserver:self forKeyPath:@"crop"];
	[zoomCropEditView release];
	zoomCropEditView = nil;

	[lowResolutionBar release];
	lowResolutionBar = nil;

	[originalFilterDisplay release];
	[blackWhiteFilterDisplay release];
	[sepiaFilterDisplay release];

	[originalLabel release];
	[blackWhiteLabel release];
	[sepiaLabel release];

	[super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	[self applyBackgroundGradient];

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(handleCancel:)] autorelease];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleDone:)] autorelease];


	CGFloat bottomBarHeight = 100;

	// Leave a border around the crop area, and account for the status and navigation bars
	// and leave enough room at the bottom for the live-preview filters
	CGFloat borderPadding = 10;
	CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
	CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
	CGSize frameSize = CGSizeMake( 320 - ( 2 * borderPadding ), 480 - bottomBarHeight - statusBarHeight - navigationBarHeight - ( 2 * borderPadding ) );
	zoomCropEditView = [[ZoomCropEditView alloc] initWithImageElement:_imageElement andFrameSize:frameSize];
	CGPoint center = self.view.center;
	center.y -= bottomBarHeight / 2;
	zoomCropEditView.center = center;
	[self.view addSubview:zoomCropEditView];

	[zoomCropEditView addObserver:self forKeyPath:@"crop" options:NSKeyValueObservingOptionNew context:NULL];

	// Low resolution top bar
	lowResolutionBar = [[LowResolutionBar alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, 40 )];
	lowResolutionBar.hidden = YES;
	[self.view addSubview:lowResolutionBar];
    
    // "Draw" horizontal rule that separates the cropper from the filters
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake( 0, 310, self.view.bounds.size.width, 1 )];
    lineView.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    [self.view addSubview:lineView];
    [lineView release];

	// Live-preview filters

	// Spacing is 8 94 10 94 10 94 8

	// Figure out the max size that fits into a 94x94 square but maintains the proper aspect ratio
	CGSize imageElementSize = CGSizeMake( [_imageElement.width floatValue], [_imageElement.height floatValue] );
	CGSize livePreviewAvailableSize = CGSizeMake( 94, 94 );
	CGSize livePreviewActualSize = fitSizeInSize( imageElementSize, livePreviewAvailableSize );

	CGRect livePreviewFrame = CGRectMake( 8, 315, livePreviewActualSize.width, livePreviewActualSize.height );

	// Adjust position based on available area vs. area that the image actually takes up
	livePreviewFrame.origin.x += ( livePreviewAvailableSize.width - livePreviewActualSize.width ) / 2;
	livePreviewFrame.origin.y += ( livePreviewAvailableSize.height - livePreviewActualSize.height ) / 2;

	originalFilterDisplay = [[FramedPhoto alloc] initWithFrame:livePreviewFrame];
	originalFilterDisplay.imageElement = [[_imageElement mutableCopy] autorelease];
	originalFilterDisplay.imageElement.tintType = ImageElementTintTypeNone;
	[self.view addSubview:originalFilterDisplay];

	livePreviewFrame.origin.x += livePreviewAvailableSize.width + 10;
	blackWhiteFilterDisplay = [[FramedPhoto alloc] initWithFrame:livePreviewFrame];
	blackWhiteFilterDisplay.imageElement = [[_imageElement mutableCopy] autorelease];
	blackWhiteFilterDisplay.imageElement.tintType = ImageElementTintTypeBlackWhite;
	[self.view addSubview:blackWhiteFilterDisplay];

	livePreviewFrame.origin.x += livePreviewAvailableSize.width + 10;
	sepiaFilterDisplay = [[FramedPhoto alloc] initWithFrame:livePreviewFrame];
	sepiaFilterDisplay.imageElement = [[_imageElement mutableCopy] autorelease];
	sepiaFilterDisplay.imageElement.tintType = ImageElementTintTypeSepia;
	[self.view addSubview:sepiaFilterDisplay];

	// Labels underneath the filters

	CGRect labelFrame = CGRectMake( 8, 400, 94, 20 );

	originalLabel = [[UILabel alloc] initWithFrame:labelFrame];
	originalLabel.text = @"Original";
	originalLabel.textAlignment = UITextAlignmentCenter;
	originalLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:originalLabel];

	labelFrame.origin.x += labelFrame.size.width + 10;
	blackWhiteLabel = [[UILabel alloc] initWithFrame:labelFrame];
	blackWhiteLabel.text = @"Black & White";
	blackWhiteLabel.textAlignment = UITextAlignmentCenter;
	blackWhiteLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:blackWhiteLabel];

	labelFrame.origin.x += labelFrame.size.width + 10;
	sepiaLabel = [[UILabel alloc] initWithFrame:labelFrame];
	sepiaLabel.text = @"Sepia";
	sepiaLabel.textAlignment = UITextAlignmentCenter;
	sepiaLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:sepiaLabel];

	[self updateSelectedFilter];

	// Recognize taps on the live preview filters

	UITapGestureRecognizer *tapGestureRecognizer;

	tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilterTap:)];
	[originalFilterDisplay addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];

	tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilterTap:)];
	[blackWhiteFilterDisplay addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];

	tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilterTap:)];
	[sepiaFilterDisplay addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];

	[self updateDisplayForCropChange];
}

- (void)applyBackgroundGradient
{
	// Initialize the gradient layer
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];

	// Create a bounding area for the empty space at the bottom
	CGRect bounds = self.view.bounds;
	gradientLayer.bounds = self.view.bounds;
	gradientLayer.position = CGPointMake( CGRectGetMidX( bounds ), CGRectGetMidY( bounds ) );

	UIColor *highColor = [UIColor colorWithRed:0x00 / 255.0 green:0x00 / 255.0 blue:0x00 / 255.0 alpha:1];
	UIColor *lowColor = [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1];
	gradientLayer.colors = [NSArray arrayWithObjects:(id) [highColor CGColor], (id) [lowColor CGColor], nil];

	NSNumber *stopOne = [NSNumber numberWithFloat:0.70];
	NSNumber *stopTwo = [NSNumber numberWithFloat:1];
	gradientLayer.locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];

	[self.view.layer insertSublayer:gradientLayer atIndex:0];
	[gradientLayer release];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	[zoomCropEditView removeObserver:self forKeyPath:@"crop"];
	[zoomCropEditView release];
	zoomCropEditView = nil;

	[lowResolutionBar release];
	lowResolutionBar = nil;

	[originalFilterDisplay release];
	originalFilterDisplay = nil;

	[blackWhiteFilterDisplay release];
	blackWhiteFilterDisplay = nil;

	[sepiaFilterDisplay release];
	sepiaFilterDisplay = nil;

	[originalLabel release];
	originalLabel = nil;

	[blackWhiteLabel release];
	blackWhiteLabel = nil;

	[sepiaFilterDisplay release];
	sepiaFilterDisplay = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

#pragma mark - Actions

- (void)handleCancel:(id)sender
{
    [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Edit Photo:Cancel"];
    
	if ( [_delegate respondsToSelector:@selector(imageElementEditorDidCancelEditing:)] )
	{
		[_delegate imageElementEditorDidCancelEditing:self];
	}

	[self dismissModalViewControllerAnimated:YES];
}

- (void)handleFilterTap:(UITapGestureRecognizer *)sender
{
	// TRICKY: Set the type to none first so we don't have filters applying on top of filters.
	// There is note about this in the ZoomCropEditView, and should be fixed there.
	zoomCropEditView.tintType = ImageElementTintTypeNone;
	zoomCropEditView.tintType = ( (FramedPhoto *) sender.view ).imageElement.tintType;

    NSString *filterName = nil;
    switch ( zoomCropEditView.tintType )
	{
		case ImageElementTintTypeNone:
			filterName = @"No Tint";
            break;
            
		case ImageElementTintTypeBlackWhite:
			filterName = @"Grayscale Tint";
			break;
            
		case ImageElementTintTypeSepia:
            filterName = @"Sepia Tint";
            break;
    }
    [[AnalyticsModel sharedAnalyticsModel] trackPageview:[@"m:Edit Photo:" stringByAppendingString:filterName]];
    
	[self updateSelectedFilter];
}

- (void)updateSelectedFilter
{
	UIFont *selectedFont = [UIFont boldSystemFontOfSize:11];
	UIFont *regularFont = [UIFont boldSystemFontOfSize:11];

	UIColor *selectedColor = [UIColor whiteColor];
	UIColor *regularColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1];

	originalLabel.font = regularFont;
	originalLabel.textColor = regularColor;
	blackWhiteLabel.font = regularFont;
	blackWhiteLabel.textColor = regularColor;
	sepiaLabel.font = regularFont;
	sepiaLabel.textColor = regularColor;

	switch ( zoomCropEditView.tintType )
	{
		case ImageElementTintTypeNone:
			originalLabel.font = selectedFont;
			originalLabel.textColor = selectedColor;
			break;

		case ImageElementTintTypeBlackWhite:
			blackWhiteLabel.font = selectedFont;
			blackWhiteLabel.textColor = selectedColor;
			break;

		case ImageElementTintTypeSepia:
			sepiaLabel.font = selectedFont;
			sepiaLabel.textColor = selectedColor;
			break;
	}


}

- (void)handleDone:(id)sender
{
    [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Edit Photo:Apply"];
    
	if ( [_delegate respondsToSelector:@selector(imageElementEditor:didFinishEditing:)] )
	{
		[_delegate imageElementEditor:self didFinishEditing:_imageElement];
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
		[self handleCancel:nil];
	}
}

#pragma mark - KVO for crop box updates

- (void)updateDisplayForCropChange
{
	CGRect resolutionIndependentCrop = zoomCropEditView.resolutionIndependentCrop;

	// Apply the crop to all of the live-preview filter images
	originalFilterDisplay.imageElement.resolutionIndependentCrop = resolutionIndependentCrop;
	blackWhiteFilterDisplay.imageElement.resolutionIndependentCrop = resolutionIndependentCrop;
	sepiaFilterDisplay.imageElement.resolutionIndependentCrop = resolutionIndependentCrop;

	if ( [zoomCropEditView isLowResolution] )
	{
		// Show the bar if it's not already showing
		if ( lowResolutionBar.hidden )
		{
			lowResolutionBar.hidden = NO;
		}
	}
	else // Not low resolution
	{
		// Hide the low res bar if it's visible
		if ( !lowResolutionBar.hidden )
		{
			lowResolutionBar.hidden = YES;
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( object == zoomCropEditView && [keyPath isEqualToString:@"crop"] )
	{
		[self updateDisplayForCropChange];
	}
}

#pragma mark Accessors

- (CGRect)resolutionIndependentCrop
{
	return zoomCropEditView.resolutionIndependentCrop;
}

- (ImageElementTintType)tintType
{
	return zoomCropEditView.tintType;
}

@end
