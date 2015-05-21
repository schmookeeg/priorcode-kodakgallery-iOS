//
//  SettingsDataSource.m
//  MobileApp
//
//  Created by Darron Schall on 8/25/11.
//

#import "SettingsDataSource.h"
#import "KGTableRightCaptionItemCell.h"
#import "SettingsSignOutItem.h"
#import "SettingsSignOutTableCell.h"

@implementation SettingsDataSource

/**
 Exactly the same as TTSectionedDataSource but typed to SettingsDataSource
 */
+ (SettingsDataSource *)dataSourceWithArrays:(id)object, ...
{
	NSMutableArray *items = [NSMutableArray array];
	NSMutableArray *sections = [NSMutableArray array];
	va_list ap;
	va_start(ap, object);
	while ( object )
	{
		if ( [object isKindOfClass:[NSString class]] )
		{
			[sections addObject:object];

		}
		else
		{
			[items addObject:object];
		}
		object = va_arg(ap, id);
	}
	va_end(ap);

	return [[[self alloc] initWithItems:items sections:sections] autorelease];
}

- (id)initWithItems:(NSArray *)items sections:(NSArray *)sections
{
	self = [super initWithItems:items sections:sections];
	if ( self )
	{
		// Initialization code here
	}
	return self;
}


/*
 Override so we can link the TTTableRightCaptionItem to our custom KGTableRightCaptionItemCell
 since the TTTableRightCaptionItemCell in the Three20 library is not implemented.
 */
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object
{
	if ( [object isKindOfClass:[TTTableRightCaptionItem class]] )
	{
		return [KGTableRightCaptionItemCell class];
	}
	else if ( [object isKindOfClass:[SettingsSignOutItem class]] )
	{
		return [SettingsSignOutTableCell class];
	}
	else
	{
		return [super tableView:tableView cellClassForObject:object];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *tableViewCell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

	if ( indexPath.section == SDSResizeSection || indexPath.section == SDSNotificationSection )
	{
		[tableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	else if ( indexPath.section == SDSDefaultSection || ( ( indexPath.section == SDSAccountSection ) && [[UserModel userModel] loggedIn] ) )
	{
		tableViewCell.accessoryType = UITableViewCellAccessoryNone;
		tableViewCell.textLabel.textAlignment = UITextAlignmentCenter;
		if ( ( indexPath.section == SDSAccountSection ) && [[UserModel userModel] loggedIn] )
		{
			[tableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
		}

	}
	else
	{
		[tableViewCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	}
	return tableViewCell;
}


@end
