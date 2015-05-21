//
//  ShareActionSheetController.h
//  MobileApp
//
//  Created by Jon Campbell on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MailComposer.h"
#import "SMSComposer.h"
#import "ShareActionSheetControllerDelegate.h"
#import "ShareModel.h"
#import "MBProgressHUD.h"

/**
 Abstract base class.
 */
@interface ShareActionSheetController : NSObject <UIActionSheetDelegate, MBProgressHUDDelegate>
{
	id <ShareActionSheetControllerDelegate> _delegate;
	id <ShareModel> _model;

	NSString *_metricsContext;

	MailComposer *_mailComposer;

	SMSComposer *_smsComposer;
	BOOL _smsAvailable;

	MBProgressHUD *_hud;
}

@property ( nonatomic, retain ) id <ShareActionSheetControllerDelegate> delegate;
@property ( nonatomic, retain ) id <ShareModel> model;

@property ( nonatomic, retain ) NSString *metricsContext;

@property ( nonatomic, retain ) MailComposer *mailComposer;
@property ( nonatomic, retain ) SMSComposer *smsComposer;

@property ( nonatomic, readonly ) MBProgressHUD *hud;

- (id)initWithDelegate:(id <ShareActionSheetControllerDelegate>)delegate model:(id <ShareModel>)model metricsContext:(NSString *)metricsContext;

- (void)processShareActionAtIndex:(int)shareIndex withTitle:(NSString *)shareTitle;

- (void)showOptions;

- (void)sendEmail;

- (void)sendFacebook;

- (void)sendAddThis;

- (void)sendSms;

@end
