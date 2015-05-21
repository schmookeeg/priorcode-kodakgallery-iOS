#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface MailComposer : NSObject <MFMailComposeViewControllerDelegate>
{
	NSString *_messageText;
	NSString *_subjectText;
	NSString *_sendToText;
	UIViewController *_viewController;
}

@property ( nonatomic, retain ) NSString *messageText;
@property ( nonatomic, retain ) NSString *subjectText;
@property ( nonatomic, retain ) NSString *sendToText;

- (MailComposer *)initWithViewController:(UIViewController *)viewController
							 messageText:(NSString *)message
							 subjectText:(NSString *)subject
							  sendToText:(NSString *)sendTo;

- (void)displayComposerSheet;

- (void)launchMailAppOnDevice;

@end

