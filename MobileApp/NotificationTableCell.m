//
//  NotificationTableCellView.m
//  MobileApp
//
//  Created by Jon Campbell on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotificationTableCell.h"
#import "NotificationTableItem.h"
#import "NSDate+FuzzyTime.h"

static const CGFloat kIconImageWidth = 65;
static const CGFloat kIconImageHeight = 65;
static const CGFloat kAvatarImageDenominator = 2.2;
static const CGFloat kLikeIconWidth = 12;
static const CGFloat kLikeIconHeight = 16;


@implementation NotificationTableCell

@synthesize avatarImageView = _avatarImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
	self = [super initWithStyle:style reuseIdentifier:identifier];

	self.captionLabel.lineBreakMode = UILineBreakModeTailTruncation;
	self.captionLabel.numberOfLines = 0;


	TTImageView *avatarImageView = [[TTImageView alloc] init];
	self.avatarImageView = avatarImageView;
	[avatarImageView release];

	[self.contentView addSubview:self.avatarImageView];

	return self;
}

- (UIImageView *)likeIcon
{
	if ( !_likeIcon )
	{
		_likeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ThumbsUpInline.png"]];
		[self.contentView addSubview:_likeIcon];
	}
	return _likeIcon;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object
{
	return kIconImageHeight;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews
{
	[super layoutSubviews];

	NotificationTableItem *item = self.object;

	CGFloat left = 0;
	CGFloat top = 2;

	_imageView2.contentMode = UIViewContentModeScaleAspectFill;
	_imageView2.clipsToBounds = YES;
	_imageView2.frame = CGRectMake( 0, 0,
			kIconImageWidth, kIconImageHeight );
	left += kIconImageWidth + kTableCellSmallMargin;

	CGFloat width = self.contentView.width - left;

	// Name
	_titleLabel.frame = CGRectMake( left, top, width, _titleLabel.font.ttLineHeight );
	top += _titleLabel.height + 2;

	// "Commented on X's photo"
	CGFloat captionLeft = left;
	if ( [item isLike] )
	{
		// Show the like icon
		[[self likeIcon] setFrame:CGRectMake( left, top, kLikeIconWidth, kLikeIconHeight )];
		captionLeft += kLikeIconWidth + 5;
	}
	else
	{
		// Zero size frame hides the like icon
		[[self likeIcon] setFrame:CGRectZero];
	}

	self.captionLabel.textColor = [UIColor grayColor];
	self.captionLabel.frame = CGRectMake( captionLeft, top, width, self.captionLabel.font.ttLineHeight );
	top += self.captionLabel.height;

	_timestampLabel.text = [[item timestamp] fuzzyStringRelativeToNow];
	_timestampLabel.frame = CGRectMake( left, top, width, _timestampLabel.font.ttLineHeight );
	_timestampLabel.alpha = !self.showingDeleteConfirmation;
	[_timestampLabel sizeToFit];

	_titleLabel.width -= _timestampLabel.width + kTableCellSmallMargin * 2;


	//avatar image
	_avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
	_avatarImageView.clipsToBounds = YES;
	_avatarImageView.urlPath = item.avatarImage;
	_avatarImageView.frame = CGRectMake( kIconImageWidth - kIconImageWidth / kAvatarImageDenominator, kIconImageHeight - kIconImageHeight / kAvatarImageDenominator, kIconImageWidth / kAvatarImageDenominator, kIconImageHeight / kAvatarImageDenominator );
	[_avatarImageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
	[_avatarImageView.layer setBorderWidth:2.0];
	[_avatarImageView.layer setShadowOffset:CGSizeMake( -2, -2 )];
	[_avatarImageView.layer setShadowRadius:1];
	[_avatarImageView.layer setShadowOpacity:0.5f];
	[_avatarImageView.layer setShadowColor:[[UIColor blackColor] CGColor]];

	// make sure avatar image is on top
	[self.contentView bringSubviewToFront:_avatarImageView];
}

- (void)dealloc
{
	self.avatarImageView = nil;
	[_likeIcon release];

	[super dealloc];
}

@end
