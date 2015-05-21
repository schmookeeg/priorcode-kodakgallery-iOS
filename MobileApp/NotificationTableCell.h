//
//  NotificationTableCellView.h
//  MobileApp
//
//  Created by Jon Campbell on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Three20/Three20+Additions.h>

@interface NotificationTableCell : TTTableMessageItemCell
{
	TTImageView *_avatarImageView;
	UIImageView *_likeIcon;
}

@property ( nonatomic, retain ) TTImageView *avatarImageView;

@end
