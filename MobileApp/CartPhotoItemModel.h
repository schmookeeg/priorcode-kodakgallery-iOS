//
//  CartPhotoItemModel.h
//  MobileApp
//
//  Created by Jon Campbell on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoModel;
@class PrintSKUModel;
@class CartModel;

@interface CartPhotoItemModel : NSObject {

@private
    PrintSKUModel *_sku;
    int _count;
    PhotoModel *_photo;
    CartModel *_cart;
}

- (NSDecimalNumber*)price;
- (id)initWithPhoto:(PhotoModel *)photoModel;

@property (nonatomic, retain) PhotoModel* photo;
@property (nonatomic, retain) PrintSKUModel* sku;
@property (nonatomic) int count;
@property (nonatomic, retain) CartModel *cart;

@end
