//
//  SPMProductList.m
//  MobileApp
//
//  Created by Darron Schall on 2/27/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "SPMProductList.h"
#import "Environment.h"

@implementation SPMProductList

@synthesize products = _products;

#pragma mark Init / Dealloc

- (void)dealloc
{
	[_products release];

	[super dealloc];
}

#pragma mark -

- (NSString *)url
{
	return [NSString stringWithFormat:kProductListMobileSkusURL, kMobileSourceId];
}

@end
