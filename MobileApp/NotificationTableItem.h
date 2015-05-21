//
//  NotificationTableItem.h
//  MobileApp
//
//  Created by Jon Campbell on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Three20/Three20+Additions.h>

@interface NotificationTableItem : TTTableMessageItem
{
	NSString *_avatarImage;
}

@property ( nonatomic, retain ) NSString *avatarImage;
@property ( nonatomic ) BOOL isLike;

@end
