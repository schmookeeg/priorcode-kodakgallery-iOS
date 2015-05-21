//
//  SMSComposer.h
//  MobileApp
//
//  Created by mikeb on 6/6/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>


@interface SMSComposer : NSObject <MFMessageComposeViewControllerDelegate>
{
	NSString *_messageText;
	UIViewController *_viewController;
}

@property ( nonatomic, retain ) NSString *messageText;

- (SMSComposer *)initWithViewController:(UIViewController *)viewController messageText:(NSString *)message;

+ (BOOL)canSendText;

@end
