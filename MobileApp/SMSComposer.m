//
//  SMSComposer.m
//  MobileApp
//
//  Created by Dev on 6/6/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//  Adapted from :  http://blog.mugunthkumar.com/coding/iphone-tutorial-how-to-send-in-app-sms/
//

#import "SMSComposer.h"

@implementation SMSComposer
@synthesize messageText;

- (SMSComposer *)initWithViewController:(UIViewController *)viewController messageText:(NSString *)message;
{

	self = [super init];

	_viewController = viewController;
	self.messageText = message;

	MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
	if ( [MFMessageComposeViewController canSendText] )
	{
		controller.body = message;
		controller.messageComposeDelegate = self;
		controller.navigationBar.barStyle = UIBarStyleBlack;
		controller.navigationBar.tintColor = nil;

		[_viewController presentModalViewController:controller animated:YES];
	}

	return self;
}

// Dismisses the sms composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	NSString *messageResult;
	// Notifies users about errors associated with the interface
	switch ( result )
	{
		case MessageComposeResultCancelled:
			messageResult = nil;
			break;
		case MessageComposeResultFailed:
			messageResult = @"Could not send your message";
			break;
		case MessageComposeResultSent:
			messageResult = nil;
			break;
		default:
			messageResult = @"Message not sent";
			break;
	}
	[_viewController dismissModalViewControllerAnimated:YES];
	if ( messageResult != nil )
	{
		[[[[UIAlertView alloc] initWithTitle:@"SMS Message Status"
									 message:messageResult delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
	}
}

+ (BOOL)canSendText
{
	return [MFMessageComposeViewController canSendText];

}

- (void)dealloc
{
	[messageText release];
	[super dealloc];
}


@end
