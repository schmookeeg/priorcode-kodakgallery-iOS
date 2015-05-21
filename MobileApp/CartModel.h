//
//  CartModel.h
//  MobileApp
//
//  Created by Jon Campbell on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StoreModel;
@class PrintToStoreCatalogModel;
@class PhotoModel;

@interface CartModel : NSObject {

@private
    StoreModel *_store;
    PrintToStoreCatalogModel *_catalog;
    NSMutableArray *_photos;
    NSString *_printSize;
    NSString *_firstName;
    NSString *_lastName;
    NSString *_email;
    int newPhotoCount;
    NSMutableArray *_lastAddedPhotos;
    BOOL _clearWebCart;
}

+ (CartModel *)cartModel;
+ (void)setCurrentCartModel:(CartModel*)cartModel;

- (void)persistCart;

- (void)restoreCart;

- (void)clearCart;

- (void)clearStoreInfo;

- (NSDecimalNumber*)subtotal;
- (NSDecimalNumber*)estimatedTax;

- (NSMutableArray *)serializePhotosToDictionary;
- (NSMutableArray *)serializeLastAddedPhotosToDictionary;


- (NSDecimalNumber*)total;
- (void)addPhotos:(NSArray *)photos;
- (void)addPhoto:(PhotoModel *)photo;
- (void)removePhotos:(NSArray *)photoIds;
- (void)removePhoto:(NSString *)photoId;
- (PhotoModel *)findPhotoFromId:(NSNumber *)photoId;


- (void)clearLastAddedPhotos;

@property (nonatomic, retain) NSMutableArray* lastAddedPhotos;
@property (nonatomic, retain) NSMutableArray* photos;
@property (nonatomic, retain) NSString* printSize;
@property (nonatomic, retain) StoreModel* store;
@property (nonatomic, retain) PrintToStoreCatalogModel* catalog;

@property (nonatomic, retain) NSString* firstName;
@property (nonatomic, retain) NSString* lastName;
@property (nonatomic, retain) NSString* email;
@property (nonatomic) int newPhotoCount;
@property (nonatomic) BOOL clearWebCart;



@end
