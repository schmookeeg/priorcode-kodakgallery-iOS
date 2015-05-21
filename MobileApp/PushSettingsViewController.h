//
//  PushSettingsViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 7/19/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import <Foundation/Foundation.h>
#import "SettingsModel.h"

@interface PushSettingsViewController : TTTableViewController
{
	SettingsModel *settings;
}

- (void)updateDataSource;


@end
