//
//  RootViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import <Three20/Three20.h>

/** READ THIS !!!!!!!!!!! 
 
 To provide the RootViewController override captability in classes that inherit from Three20 view controllers, 
 we are using this category to plug into their BaseViewController. Otherwise, all other classes that inherit 
 from UIViewController should inherit from RootViewController.
 
 The functionality of the category and RootViewcontroller should stay in sync.
    
 
*/

@interface TTBaseViewController (kg)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (BOOL)showLogo;
@end

@implementation TTBaseViewController (kg)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		_navigationBarStyle = UIBarStyleDefault;

		_statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];

		if ( [self showLogo] )
		{
			UIImage *barLogo = [UIImage imageNamed:@"Logo.png"];
			UIImageView *barLogoView = [[[UIImageView alloc] initWithImage:barLogo] autorelease];

			self.navigationItem.titleView = barLogoView;
		}

	}

	return self;
}

- (BOOL)showLogo
{
	return NO;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationBarStyle = UIBarStyleBlack;
	self.navigationBarTintColor = nil;
}

@end


@implementation RootViewController


- (id)init
{
	self = [super init];

	if ( self )
	{

		if ( [self showLogo] )
		{
			// Navigation bar logo
			UIImage *barLogo = [UIImage imageNamed:@"Logo.png"];
			UIImageView *barLogoView = [[[UIImageView alloc] initWithImage:barLogo] autorelease];

			self.navigationItem.titleView = barLogoView;
		}


	}

	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		// Navigation bar logo
		if ( [self showLogo] )
		{
			UIImage *barLogo = [UIImage imageNamed:@"Logo.png"];
			UIImageView *barLogoView = [[[UIImageView alloc] initWithImage:barLogo] autorelease];

			self.navigationItem.titleView = barLogoView;
		}


	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.tintColor = nil;
}

- (BOOL)showLogo
{
	return NO;
}

@end
