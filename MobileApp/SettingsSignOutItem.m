//
//  SettingsSignOutItem.m
//  MobileApp
//
//  Created by P. Traeg on 9/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "SettingsSignOutItem.h"

@implementation SettingsSignOutItem

@synthesize _signin;
@synthesize _emailid;
@synthesize _buttonTitle;
@synthesize buttonAction, buttonDelegate;

+ (id)itemWithText:(NSString *)text caption:(NSString *)captionText signin:(NSString *)signInText emailid:(NSString *)emailText buttonTitle:(NSString *)buttonText delegate:(id)delegate selector:(SEL)selector
{
	SettingsSignOutItem *item = [[[self alloc] init] autorelease];
	item.text = text;
	item.caption = captionText;
	item._signin = signInText;
	item._emailid = emailText;
	item._buttonTitle = buttonText;

	item.buttonDelegate = delegate;
	item.buttonAction = selector;
	return item;
}

- (id)init
{
	if ( self == [super init] )
	{
		_signin = nil;
		_emailid = nil;
		_buttonTitle = nil;
	}
	return self;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_signin);
	TT_RELEASE_SAFELY(_emailid);
	TT_RELEASE_SAFELY(_buttonTitle);
	[super dealloc];
}


- (id)initWithCoder:(NSCoder *)decoder
{
	if ( self == [super initWithCoder:decoder] )
	{
		self._signin = [decoder decodeObjectForKey:@"signIn"];
		self._emailid = [decoder decodeObjectForKey:@"email"];
		self._buttonTitle = [decoder decodeObjectForKey:@"button"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	if ( self._signin )
	{
		[encoder encodeObject:self._signin forKey:@"signIn"];
	}
	if ( self._emailid )
	{
		[encoder encodeObject:self._emailid forKey:@"email"];
	}
	if ( self._buttonTitle )
	{
		[encoder encodeObject:self._buttonTitle forKey:@"button"];
	}
}

@end

