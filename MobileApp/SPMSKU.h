//
//  SPMSKU.h
//  MobileApp
//
//  Created by Darron Schall on 2/24/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPMSKU : NSObject

@property ( nonatomic, retain ) NSString *skuId;
@property ( nonatomic, retain ) NSString *siteServicesProductId;
@property ( nonatomic, retain ) NSString *name;
@property ( nonatomic, retain ) NSString *priceBulk;
@property ( nonatomic, retain ) NSNumber *price;
@property ( nonatomic, retain ) NSNumber *salePrice;
@property ( nonatomic, retain ) NSMutableArray *bulkPrices;

/**
 * The list of template layouts available for this product/sku combination
 */
@property ( nonatomic, retain ) NSArray *layouts; // Of SPMLayout instances

@end
