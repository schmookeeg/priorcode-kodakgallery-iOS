//
//  CommentTableCellView.m
//  MobileApp
//
//  Created by Dev on 6/24/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "CommentTableCellView.h"
#import "NSDate+FuzzyTime.h"

static const CGFloat kDefaultAvatarImageWidth = 34;
static const CGFloat kDefaultAvatarImageHeight = 34;
static const CGFloat kLikeIconWidth = 12;
static const CGFloat kLikeIconHeight = 16;


@implementation CommentTableCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
	self = [super initWithStyle:style reuseIdentifier:identifier];

	self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
	self.detailTextLabel.numberOfLines = 0;

	return self;
}

- (UIImageView *)likeIcon
{
	if ( !_likeIcon )
	{
		_likeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ThumbsUpInline.png"]];
		[self.contentView addSubview:_likeIcon]; // subview will retain it
		[_likeIcon release];
	}
	return _likeIcon;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object
{
	TTTableMessageItem *item = object;

	CGFloat width = tableView.width - [tableView tableCellMargin] * 2 - kTableCellHPadding * 2 - kDefaultAvatarImageWidth;

	CGSize detailTextSize = [item.text sizeWithFont:TTSTYLEVAR(font) constrainedToSize:CGSizeMake( width, CGFLOAT_MAX )
									  lineBreakMode:UILineBreakModeWordWrap];

	CGSize textSize = [item.title sizeWithFont:TTSTYLEVAR(font) constrainedToSize:CGSizeMake( width, CGFLOAT_MAX )
								 lineBreakMode:UILineBreakModeWordWrap];

	return kTableCellVPadding * 2 + detailTextSize.height + textSize.height;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews
{
	[super layoutSubviews];

	CGFloat left = 0;
	if ( _imageView2 )
	{
		_imageView2.frame = CGRectMake( kTableCellSmallMargin, kTableCellSmallMargin,
				kDefaultAvatarImageWidth, kDefaultAvatarImageHeight );
		left += kTableCellSmallMargin + kDefaultAvatarImageWidth + kTableCellSmallMargin;

	}
	else
	{
		left = kTableCellMargin;
	}

	CGFloat width = self.contentView.width - left;
	CGFloat top = kTableCellSmallMargin;

	if ( _titleLabel.text.length )
	{
		_titleLabel.frame = CGRectMake( left, top, width, _titleLabel.font.ttLineHeight );
		top += _titleLabel.height;

	}
	else
	{
		_titleLabel.frame = CGRectZero;
	}

	// For comments we're never using captionLabel
	self.captionLabel.frame = CGRectZero;

	if ( [self.captionLabel.text isEqualToString:@"LIKE"] )
	{
		// Show the like icon
		[[self likeIcon] setFrame:CGRectMake( left, top, kLikeIconWidth, kLikeIconHeight )];
		left += kLikeIconWidth + 5;
	}
	else
	{
		// Zero size frame hides the like icon
		[[self likeIcon] setFrame:CGRectZero];
	}

	// This portion is different than the standard TTTableMessageItemCell we want the detailTextLabel
	// to grow in height as needed.  Borrowed this basic idea from TTTableSubtextItemCell
	if ( self.detailTextLabel.text.length )
	{
		[self.detailTextLabel sizeToFit];
		self.detailTextLabel.frame = CGRectMake( left, top, width, self.detailTextLabel.height );
	}
	else
	{
		self.detailTextLabel.frame = CGRectZero;
	}

	if ( _timestampLabel.text.length )
	{
		TTTableMessageItem *item = self.object;

		_timestampLabel.alpha = !self.showingDeleteConfirmation;

		_timestampLabel.top = _titleLabel.top;
		_timestampLabel.text = item.timestamp.fuzzyStringRelativeToNow;
		[_timestampLabel sizeToFit];
		_timestampLabel.left = self.contentView.width - ( _timestampLabel.width + kTableCellSmallMargin );

		_titleLabel.width -= _timestampLabel.width + kTableCellSmallMargin * 2;

	}
	else
	{
		_timestampLabel.frame = CGRectZero;
	}
}


@end
