//
//  LayoutElement.m
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "LayoutElement.h"

@implementation LayoutElement

@synthesize x = _x;
@synthesize y = _y;
@synthesize z = _z;
@synthesize width = _width;
@synthesize height = _height;

@synthesize rotation = _rotation;

#pragma mark init / dealloc

/**
 * For background on why we set iVars to nil first, see
 * http://robnapier.net/blog/implementing-nscopying-439
 */
-(id)mutableCopyWithZone:(NSZone *)zone
{
	LayoutElement *copy = [[[self class] allocWithZone:zone] init];

	copy->_x = nil;
	copy.x = self.x;

	copy->_y = nil;
	copy.y = self.y;

	copy->_width = nil;
	copy.width = self.width;

	copy->_height = nil;
	copy.height = self.height;

	copy->_rotation = nil;
	copy.rotation = self.rotation;

	return copy;
}

- (void)dealloc
{
	[_x release];
	[_y release];
	[_z release];
	[_width release];
	[_height release];
	[_rotation release];

	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p x: %@\n \
            y: %@\n \
            width: %@\n \
            height: %@\n \
            rotation: %@\n \
            z: %@\n"
            , NSStringFromClass([self class]), self, self.x, self.y, 
            self.width, self.height, self.rotation, self.z];
}

@end
