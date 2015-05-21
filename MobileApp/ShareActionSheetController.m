//
//  ShareActionSheetController.m
//  MobileApp
//
//  Created by Jon Campbell on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailComposer.h"
#import "SMSComposer.h"
#import "AddThis.h"
#import "ShareActionSheetController.h"

@interface ShareActionSheetController (Private)

/** Protected helper method to be used in the sendEmail implementation */
- (void)sendEmailWithSubject:(NSString *)subject andBody:(NSString *)body;


/** Protected helper method to be used in the sendFacebook implementation */
- (void)sendFacebookWithUrl:(NSString *)url title:(NSString *)title description:(NSString *)description;

/** Protected helper method to be used in the sendAddThis implementation */
- (void)sendAddThisWithUrl:(NSString *)url title:(NSString *)title description:(NSString *)description;


/** Protected helper method to be used in the sendSms implementation */
- (void)sendSmsWithMessage:(NSString *)message;

@end

@implementation ShareActionSheetController

@synthesize delegate = _delegate;
@synthesize model = _model;
@synthesize mailComposer = _mailComposer;
@synthesize smsComposer = _smsComposer;
@synthesize metricsContext = _metricsContext;

- (id)initWithDelegate:(id <ShareActionSheetControllerDelegate>)delegate model:(id <ShareModel>)model metricsContext:(NSString *)metricsContext
{
	self = [super init];
	if ( self )
	{
		self.delegate = delegate;
		self.model = model;
		self.metricsContext = metricsContext;
	}
	return self;
}

- (MBProgressHUD *)hud
{
	if ( !_hud )
	{
		_hud = [[MBProgressHUD alloc] initWithView:_delegate.navigationController.view];
		_hud.delegate = self;
		_hud.removeFromSuperViewOnHide = YES;
		[_delegate.navigationController.view addSubview:_hud];
	}

	return _hud;
}

- (void)hudWasHidden
{
	// Free up memory when the hud goes away by release it safely (which prevents
	// a dual-release in dealloc as well)
	[_hud release];
	_hud = nil;
}

- (void)showOptions
{
	NSLog( @"ShareActionSheetController showShare NOOP" );
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog( @"ShareActionSheetController actionSheet:didDismissWithButtonIndex NOOP" );
}

- (void)processShareActionAtIndex:(int)shareIndex withTitle:(NSString *)shareTitle
{
	NSLog( @"ShareActionSheetController processShareActionAtIndex: NOOP" );
}


- (void)sendEmail
{
	NSString *emailHTML = [self.model shareEmailText];
	NSString *subjectText = [self.model shareSubjectText];

	[self sendEmailWithSubject:subjectText andBody:emailHTML];
}

- (void)sendEmailWithSubject:(NSString *)subject andBody:(NSString *)body
{
	if ( [_delegate isKindOfClass:[UIViewController class]] )
	{
		UIViewController *viewController = (UIViewController *) _delegate;
		self.mailComposer = [[[MailComposer alloc] initWithViewController:viewController messageText:body subjectText:subject sendToText:nil] autorelease];
	}
	else
	{
		NSLog( @"Could not open mail composer." );
	}

	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Share:Email" eventName:@"event73"];
}

- (void)sendSms
{
	NSString *smsMessage = [self.model shareSMSText];

	[self sendSmsWithMessage:smsMessage];
}

- (void)sendSmsWithMessage:(NSString *)message
{
	if ( [_delegate isKindOfClass:[UIViewController class]] )
	{
		UIViewController *viewController = (UIViewController *) _delegate;
		self.smsComposer = [[(SMSComposer *) [SMSComposer alloc] initWithViewController:viewController messageText:message] autorelease];
	}
	else
	{
		NSLog( @"Could not open sms composer." );
	}

	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Share:SMS" eventName:@"event73"];
}

- (void)sendFacebook
{
	NSString *url = [self.model shareURL];
	NSString *title = [self.model shareSubjectText];
	NSString *description = [self.model shareDescriptionText];

	[self sendFacebookWithUrl:url title:title description:description];
}

- (void)sendFacebookWithUrl:(NSString *)url title:(NSString *)title description:(NSString *)description
{
	[AddThisSDK shareURL:url
			 withService:@"facebook"
				   title:title
			 description:description];

	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Share:Facebook" eventName:@"event73"];
}

- (void)sendAddThis
{
	NSString *url = [self.model shareURL];
	NSString *title = [self.model shareSubjectText];
	NSString *description = [self.model shareDescriptionText];

	[self sendAddThisWithUrl:url title:title description:description];
}

- (void)sendAddThisWithUrl:(NSString *)url title:(NSString *)title description:(NSString *)description
{
	[AddThisSDK presentAddThisMenuForURL:url
							   withTitle:title
							 description:description];

	[[AnalyticsModel sharedAnalyticsModel] trackEvent:@"m:Share:AddThis" eventName:@"event73"];
}

- (void)dealloc
{
	[_mailComposer release];
	[_smsComposer release];
	[_metricsContext release];
	[_delegate release];
	[_model release];
	[_hud release];

	[super dealloc];
}

@end
