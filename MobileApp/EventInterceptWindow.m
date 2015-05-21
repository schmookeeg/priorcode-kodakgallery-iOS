//
//  EventInterceptWindow.m
//  CMPopTipViewDemo
//
//  Created by Dev on 9/12/11.
//  Copyright 2011 Chris Miles. All rights reserved.
//

#import "EventInterceptWindow.h"


@implementation EventInterceptWindow

@synthesize eventInterceptDelegate;

- (void)sendEvent:(UIEvent *)event
{
	if ( [eventInterceptDelegate interceptEvent:event] == NO )
	{
		[super sendEvent:event];
	}
}

@end

