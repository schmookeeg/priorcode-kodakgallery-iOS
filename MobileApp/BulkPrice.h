//
//  BulkPrice.h
//  MobileApp
//
//  Created by Amit Chauhan on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BulkPrice : NSObject

@property ( nonatomic, retain ) NSNumber *lowBound;
@property ( nonatomic, retain ) NSNumber *highBound;
@property ( nonatomic, retain ) NSNumber *price;
@property ( nonatomic, retain ) NSNumber *salePrice;

@end
