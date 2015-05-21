//
//  CartPhotoItemModel.m
//  MobileApp
//
//  Created by Jon Campbell on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CartPhotoItemModel.h"
#import "PhotoModel.h"
#import "PrintSKUModel.h"
#import "CartModel.h"

@implementation CartPhotoItemModel
@synthesize sku = _sku;
@synthesize count = _count;
@synthesize photo = _photo;
@synthesize cart = _cart;


- (void)dealloc {
    [_sku release];
    [_photo release];
    [_cart release];
    [super dealloc];
}

- (NSDecimalNumber *)price {
    return nil;

}

- (id)initWithPhoto:(PhotoModel *)photoModel {
    self = [super init];
    if (self) {
        self.photo = photoModel;
    }
    return self;
}


@end
