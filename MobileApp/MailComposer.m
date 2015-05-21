#import "MailComposer.h"

@implementation MailComposer
@synthesize messageText, subjectText, sendToText;

- (MailComposer *)initWithViewController:(UIViewController *)viewController
							 messageText:(NSString *)message
							 subjectText:(NSString *)subject
							  sendToText:(NSString *)sendTo
{
	// This sample can run on devices running iPhone OS 2.0 or later  
	// The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
	// So, we must verify the existence of the above class and provide a workaround for devices running 
	// earlier versions of the iPhone OS. 
	// We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
	// We launch the Mail application on the device, otherwise.

	_viewController = viewController;
	self.messageText = message;
	self.subjectText = subject;
	if ( sendTo && [sendTo length] > 0 )
	{
		self.sendToText = sendTo;
	}

	Class mailClass = ( NSClassFromString( @"MFMailComposeViewController" ) );
	if ( mailClass != nil )
	{
		// We must always check whether the current device is configured for sending emails
		if ( [mailClass canSendMail] )
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
	return self;
}

#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void)displayComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	picker.navigationBar.barStyle = UIBarStyleBlack;
	picker.navigationBar.tintColor = nil;

	[picker setSubject:self.subjectText];

	if ( self.sendToText && [self.sendToText length] > 0 )
	{
		[picker setToRecipients:[NSArray arrayWithObjects:self.sendToText, nil]];
	}
	// Fill out the email body text
	NSString *emailBody = self.messageText;
	[picker setMessageBody:emailBody isHTML:YES];

	[_viewController presentModalViewController:picker animated:YES];
	[picker release];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	NSString *messageResult;
	// Notifies users about errors associated with the interface
	switch ( result )
	{
		case MFMailComposeResultCancelled:
			messageResult = nil;
			break;
		case MFMailComposeResultSaved:
			messageResult = @"Your message was saved";
			break;
		case MFMailComposeResultSent:
			messageResult = nil;
			break;
		case MFMailComposeResultFailed:
			messageResult = @"Could not send your message";
			break;
		default:
			messageResult = @"Message not sent";
			break;
	}

	[_viewController dismissModalViewControllerAnimated:YES];

	if ( messageResult != nil )
	{
		[[[[UIAlertView alloc] initWithTitle:@"Mail Message Status"
									 message:messageResult delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
	}
}


#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
- (void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
	NSString *body = @"&body=It is raining in sunny California!";

	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


#pragma mark -
#pragma mark Unload views

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.messageText = nil;
	self.sendToText = nil;
	self.subjectText = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	self.messageText = nil;
	self.sendToText = nil;
	self.subjectText = nil;
	[super dealloc];
}

@end
