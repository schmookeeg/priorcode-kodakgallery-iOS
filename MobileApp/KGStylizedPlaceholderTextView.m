//
//  KGStylizedPlaceholderTextView.m
//  MobileApp
//
//  Created by Darron Schall on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KGStylizedPlaceholderTextView.h"
#import <QuartzCore/QuartzCore.h>

@interface KGStylizedPlaceholderTextView ()

- (void)initializeStyle;

@end

@implementation KGStylizedPlaceholderTextView

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
	// Draw border with rounded corners
	self.layer.borderWidth = 1;
	self.layer.borderColor = [[UIColor colorWithRed:( 171.0 / 255.0 ) green:( 171.0 / 255.0 ) blue:( 171.0 / 255.0 ) alpha:1.0] CGColor];
	self.layer.cornerRadius = 10;
	self.clipsToBounds = YES;
}

@end
