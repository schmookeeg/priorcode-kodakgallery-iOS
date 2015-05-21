//
//  SettingsViewController.h
//  MobileApp
//
//  Created by mikeb on 7/11/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Three20/Three20.h>
#import <Foundation/Foundation.h>
#import "MailComposer.h"
#import "MBProgressHUD.h"

@interface SettingsViewController : TTTableViewController <MBProgressHUDDelegate>
{
	int slideshowLength;
	BOOL resizeUploads;
	UISwitch *resizeUploadsSwitch;
	MailComposer *_mailComposer;
	MBProgressHUD *_hud;
}

- (void)updateDataSource;

- (void)toggleResizeUploads:(id)sender;

@property ( nonatomic, retain ) MailComposer *mailComposer;
@property ( nonatomic, readonly ) MBProgressHUD *hud;

@end
