//
//  KGStylizedTextField.m
//  MobileApp
//
//  Created by Darron Schall on 8/23/11.
//

#import "KGStylizedTextField.h"
#import <QuartzCore/QuartzCore.h>

@interface KGStylizedTextField ()

- (void)initializeStyle;

@end

@implementation KGStylizedTextField


- (void)awakeFromNib
{
	[super awakeFromNib];

	[self initializeStyle];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		[self initializeStyle];

	}
	return self;
}

- (void)initializeStyle
{
	self.font = [UIFont fontWithName:@"Helvetica" size:17.0];
	self.adjustsFontSizeToFitWidth = NO;
	self.minimumFontSize = 17.0;

	// Draw a border with rounded corners
	self.borderStyle = UITextBorderStyleNone;
	self.layer.borderWidth = 1;
	self.layer.borderColor = [[UIColor colorWithRed:( 171.0 / 255.0 ) green:( 171.0 / 255.0 ) blue:( 171.0 / 255.0 ) alpha:1.0] CGColor];
	self.layer.cornerRadius = 10;
	self.clipsToBounds = YES;

	// Set left padding so the text isn't up against the edge using leftView trick
	UIView *paddingView = [[[UIView alloc] initWithFrame:CGRectMake( 0, 0, 9, 20 )] autorelease];
	[paddingView setUserInteractionEnabled:NO];
	self.leftView = paddingView;
	self.leftViewMode = UITextFieldViewModeAlways;
}

@end
