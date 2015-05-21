//
//  SPMProduct.h
//  MobileApp
//
//  Created by Darron Schall on 2/24/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPMProduct : NSObject

@property ( nonatomic, retain ) NSString *productId;
@property ( nonatomic, retain ) NSString *type;
@property ( nonatomic, retain ) NSString *catId;
@property ( nonatomic, retain ) NSMutableArray *skus;

@end
