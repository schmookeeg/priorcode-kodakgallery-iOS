//
//  SPMProduct.m
//  MobileApp
//
//  Created by Darron Schall on 2/24/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "SPMProduct.h"

@implementation SPMProduct

@synthesize productId = _productId;
@synthesize type = _type;
@synthesize catId = _catId;
@synthesize skus = _skus;

#pragma mark init / dealloc

- (void)dealloc
{
	[_productId release];
	[_type release];
	[_catId release];
	[_skus release];

	[super dealloc];
}

- (NSString *)description 
{
	return [NSString stringWithFormat:@"<%@:%p Product Id: %@\n Type: %@\n catId: %@\n SKUs: %@", NSStringFromClass([self class]), (void *) self, self.productId, self.type, self.catId, self.skus];
}

@end
