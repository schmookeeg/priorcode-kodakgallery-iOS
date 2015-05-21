//
//  EventInterceptWindow.h
//  CMPopTipViewDemo
//
//  Created by mikeb on 9/12/11.
//  Copyright 2011 Chris Miles. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol EventInterceptWindowDelegate
- (BOOL)interceptEvent:(UIEvent *)event; // return YES if event handled
@end


@interface EventInterceptWindow : UIWindow
{
	// It would appear that using the variable name 'delegate' in any UI Kit
	// subclass is a really bad idea because it can occlude the same name in a
	// superclass and silently break things like autorotation.
	id <EventInterceptWindowDelegate> eventInterceptDelegate;
}

@property ( nonatomic, assign ) id <EventInterceptWindowDelegate> eventInterceptDelegate;

@end

