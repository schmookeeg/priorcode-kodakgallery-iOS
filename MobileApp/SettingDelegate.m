//
//  SettingDelegate.m
//  MobileApp
//
//  Created by Diaspark on 9/19/11.
//  Copyright 2011 Diaspark Inc.. All rights reserved.
//

#import "SettingDelegate.h"
#import "UserModel.h"

@implementation SettingDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat retVal;
	if ( indexPath.section == 0 && [[UserModel userModel] loggedIn] )
	{
		retVal = 85.0f;
	}
	else
	{
		retVal = 44.0f;
	}
	return retVal;
}

@end
