//
//  SPMProjectTableItemCell.m
//  MobileApp
//
//  Created by Darron Schall on 2/28/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "SPMProjectTableItemCell.h"
#import "TTTAttributedLabel.h"

@interface SPMProjectTableItemCell (Private)

- (void)prepareProject:(SPMProject *)project forColumn:(int)index;

@end

@implementation SPMProjectTableItemCell

#pragma mark init / dealloc

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
	if ( self )
	{
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	return self;
}

- (void)dealloc
{
	[_item release];

	[super dealloc];
}

#pragma mark TTTableViewCell

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object
{
	// FIXME: Implement. Maybe hard-coding a value is good enough.
	return 178.0;
}

#pragma mark UIView

- (void)layoutSubviews
{
	[super layoutSubviews];
}

#pragma mark -

- (id)object
{
	return _item;
}

- (void)setObject:(id)object
{
	if ( _item != object )
	{
		[object retain];
		[_item release];
		_item = object;

        // We are reusing cells. So let's first remove all subViews before creating new ones
        NSArray *subViews = [self.contentView subviews];
        for (UIView *view in subViews)
        {
            [view removeFromSuperview];
        }
        
        // Lets build projects now
		[self prepareProject:_item.project1 forColumn:1];
		[self prepareProject:_item.project2 forColumn:2];
	}
}

- (void)prepareProject:(SPMProject *)project forColumn:(int)index
{
	if ( project == nil )
	{
		return;
	}
    
	// Canvas Renderer (project thumbnail live preview)
	CanvasRenderer *canvasRenderer = [[CanvasRenderer alloc] init];
	canvasRenderer.frame = CGRectMake( 20.0, 10.0, 130.0, 130.0 );

	if ( index == 2 )
	{
		CGRect rect = canvasRenderer.frame;
		rect.origin.x = 170;
		canvasRenderer.frame = rect;
	}

	canvasRenderer.page = project.page;

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(canvasRendererTap:)];
	[canvasRenderer addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];

    // Show the shadow
	canvasRenderer.clipsToBounds = NO;
	canvasRenderer.layer.shadowColor = [UIColor blackColor].CGColor;
	canvasRenderer.layer.shadowOffset = CGSizeMake(-2, 2);
	canvasRenderer.layer.shadowOpacity = 0.7;

	[self.contentView addSubview:canvasRenderer];
	[canvasRenderer release];


	// SKU Name
	UILabel *name = [[[UILabel alloc] init] autorelease];
	[name setText:project.productConfiguration.sku.name];
	name.textAlignment = UITextAlignmentCenter;
	name.font = [UIFont systemFontOfSize:11];
    name.textColor = [UIColor blackColor];
    name.backgroundColor = [UIColor  clearColor];

	CGRect rect = canvasRenderer.frame;
	rect.origin.y = rect.origin.y + rect.size.height + 10;
	rect.size.height = 10;
	name.frame = rect;
	[self.contentView addSubview:name];

	// SKU Price
	UILabel *salePrice, *price;

	NSString *priceStr, *salePriceStr;
	if ( [project.productConfiguration.sku.priceBulk isEqualToString:@"true"] )
	{
		priceStr = [[[project.productConfiguration.sku.bulkPrices objectAtIndex:0] price] stringValue];
		salePriceStr = [[[project.productConfiguration.sku.bulkPrices objectAtIndex:0] salePrice] stringValue];
	}
	else
	{
		priceStr = [project.productConfiguration.sku.price stringValue];
		salePriceStr = [project.productConfiguration.sku.salePrice stringValue];
	}

	if ( priceStr != nil )
	{
		if ( salePriceStr != nil )
		{
            // Price (strikethrough) and Sale Price
            price = [[[TTTAttributedLabel alloc] init] autorelease];

			NSMutableAttributedString *formattedPrice = [[NSMutableAttributedString alloc] initWithString:[@"$" stringByAppendingString:priceStr]];
			NSRange priceRange = NSMakeRange( 0, formattedPrice.length );

			// Font and size - original price
			UIFont *font = [UIFont systemFontOfSize:11.0];
			CTFontRef fontRef = CTFontCreateWithName( (CFStringRef) font.fontName, font.pointSize, nil );
			[formattedPrice addAttribute:(NSString *) kCTFontAttributeName value:(id) fontRef range:priceRange];
			CFRelease( fontRef );

			// Text color - original price in black
			[formattedPrice addAttribute:(NSString *) kCTForegroundColorAttributeName
								 value:(id) [UIColor blackColor].CGColor
								 range:priceRange];

			// Strike-through the original price
			[formattedPrice addAttribute:kTTTStrikeOutAttributeName value:[NSNumber numberWithBool:YES] range:priceRange];

			// Right align the original price
			CTTextAlignment theAlignment = kCTRightTextAlignment;
			CFIndex theNumberOfSettings = 1;
			CTParagraphStyleSetting theSettings[1] = { { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment } };
			CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate( theSettings, theNumberOfSettings );
			[formattedPrice addAttribute:(NSString *) kCTParagraphStyleAttributeName value:(id) theParagraphRef range:priceRange];
			CFRelease( theParagraphRef );

			price.backgroundColor = [UIColor clearColor];
			price.adjustsFontSizeToFitWidth = NO;

			price.text = formattedPrice;
			[formattedPrice release];


            rect = name.frame;
            rect.origin.y = rect.origin.y + rect.size.height + 5;
            rect.size.width = rect.size.width/2 - 2;
            rect.size.height = 14;
            price.frame = rect;
            [self.contentView addSubview:price];

            // Sale price in red
			salePrice = [[[UILabel alloc] init] autorelease];
			[salePrice setText:[@"$" stringByAppendingString:salePriceStr]];
            salePrice.textAlignment = UITextAlignmentLeft;
            salePrice.font = [UIFont boldSystemFontOfSize:11];
            salePrice.textColor = [UIColor redColor];
            salePrice.backgroundColor = [UIColor clearColor];
            
            rect.origin.x = rect.origin.x + rect.size.width + 4;
            salePrice.frame = rect;
            [self.contentView addSubview:salePrice];
		}
		else
		{
            // NO sale, so just showing regular Price
            price = [[[UILabel alloc] init] autorelease];
            
			[price setText:[@"$" stringByAppendingString:priceStr]];
            price.textAlignment = UITextAlignmentCenter;
            price.font = [UIFont boldSystemFontOfSize:12];
            price.textColor = [UIColor blackColor];
            price.backgroundColor = [UIColor clearColor];
            rect = name.frame;
            rect.origin.y = rect.origin.y + rect.size.height + 5;
            rect.size.height = 10;
            price.frame = rect;
            [self.contentView addSubview:price];
		}
	}
    
}

- (void)canvasRendererTap:(UITapGestureRecognizer *)sender
{
	if ( _item.delegate && _item.selector )
	{
		// Determine if we navigate to project 1 or project 2 in the item.
		SPMProject *project;
		if ( _item.project1.page == ( (CanvasRenderer *) sender.view ).page )
		{
			project = _item.project1;
		}
		else
		{
			project = _item.project2;
		}
		[_item.delegate performSelector:_item.selector withObject:project];
	}
}

@end
