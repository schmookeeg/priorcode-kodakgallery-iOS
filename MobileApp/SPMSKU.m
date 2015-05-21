//
//  SPMSKU.m
//  MobileApp
//
//  Created by Darron Schall on 2/24/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "SPMSKU.h"

@implementation SPMSKU

@synthesize skuId = _skuId;
@synthesize siteServicesProductId = _siteServicesProductId;
@synthesize name = _name;
@synthesize priceBulk = _priceBulk;
@synthesize price = _price;
@synthesize salePrice = _salePrice;
@synthesize bulkPrices = _bulkPrices;
@synthesize layouts = _layouts;

#pragma mark init / dealloc

- (void)dealloc
{
	[_skuId release];
	[_siteServicesProductId release];
	[_name release];
	[_priceBulk release];
	[_price release];
	[_salePrice release];
	[_bulkPrices release];
	[_layouts release];

	[super dealloc];
}

- (NSString *)description 
{
	return [NSString stringWithFormat:@"<%@:%p Sku Id: %@\n \
                siteServicesProductId: %@\n \
                name: %@\n \
                priceBulk: %@\n \
                price: %@\n \
                salePrice: %@\n \
                bulkPrices: %@\n \
                layouts: %@\n"
            , NSStringFromClass([self class]), self, self.skuId, self.siteServicesProductId, 
            self.name, self.priceBulk, self.price, self.salePrice, self.bulkPrices, self.layouts];
}

@end
