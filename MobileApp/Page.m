//
//  Page.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "Page.h"

@implementation Page

@synthesize x = _x;
@synthesize y = _y;
@synthesize width = _width;
@synthesize height = _height;

@synthesize finishedLayoutArea = _finishedLayoutArea;
@synthesize workingArea = _workingArea;

@synthesize layout = _layout;

@synthesize background = _background;

#pragma mark init / dealloc

- (void)dealloc
{
	[_x release];
	[_y release];
	[_width release];
	[_height release];

	[_layout release];
	[_background release];

	[super dealloc];
}

#pragma mark -


@end
