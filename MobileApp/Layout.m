//
//  Layout.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "Layout.h"

@implementation Layout

@synthesize x = _x;
@synthesize y = _y;
@synthesize width = _width;
@synthesize height = _height;

@synthesize elements = _elements;

@synthesize layoutSyle = _layoutSyle;

#pragma mark Init / Dealloc

- (id)init
{
	self = [super init];

	if ( self )
	{
		_elements = [[NSMutableArray alloc] init];
	}

	return self;
}

- (void)dealloc
{
	[_x release];
	[_y release];
	[_width release];
	[_height release];

	[_elements release];

	[super dealloc];
}

@end
