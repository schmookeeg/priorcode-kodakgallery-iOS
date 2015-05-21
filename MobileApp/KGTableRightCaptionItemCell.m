//
//  KGTableRightCaptionItemCell.m
//  MobileApp
//
//  Created by Darron Schall on 8/25/11.
//

#import "KGTableRightCaptionItemCell.h"

@implementation KGTableRightCaptionItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
	self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
	if ( self )
	{
		// TODO Should we set fonts and colors and such like TTTableCaptionItemCell does?
		// It doesn't seem necessary right now, so omitted...
	}
	return self;
}

- (void)setObject:(id)object
{
	if ( _item != object )
	{
		[super setObject:object];

		TTTableRightCaptionItem *item = object;
		self.textLabel.text = item.text;
		self.detailTextLabel.text = item.caption;
	}
}

- (UILabel *)captionLabel
{
	return self.textLabel;
}


@end
