//
//  BulkPrice.m
//  MobileApp
//
//  Created by Amit Chauhan on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BulkPrice.h"

@implementation BulkPrice

@synthesize lowBound = _lowBound;
@synthesize highBound = _highBound;
@synthesize price = _price;
@synthesize salePrice = _salePrice;

#pragma mark init / dealloc

- (void)dealloc
{
	[_lowBound release];
	[_highBound release];
	[_price release];
	[_salePrice release];
	[super dealloc];
}

- (NSString *)description 
{
	return [NSString stringWithFormat:@"<%@:%p \
            %@ - %@: $%@ (SalePrice:%@)"
            , NSStringFromClass([self class]), (void *) self, self.lowBound, self.highBound,
            self.price, self.salePrice];
}

@end
