//
//  CartModel.m
//  MobileApp
//
//  Created by Jon Campbell on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CartModel.h"
#import "StoreModel.h"
#import "PrintToStoreCatalogModel.h"
#import "UserModel.h"
#import "PhotoModel.h"
#import "CartPhotoItemModel.h"

#define kCartArchivePath @"cartData-store.plist"

static CartModel *currentCartModel;

@interface CartModel (Private)

- (void)sendUpdatedCartNotification;

@end

@implementation CartModel
@synthesize store = _store;
@synthesize catalog = _catalog;
@synthesize photos = _photos;
@synthesize printSize = _printSize;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize email = _email;
@synthesize lastAddedPhotos = _lastAddedPhotos;
@synthesize newPhotoCount = newPhotoCount;
@synthesize clearWebCart = _clearWebCart;


- (NSMutableArray *)serializePhotosToDictionary {

    NSMutableArray *photos = [NSMutableArray array];

    for (CartPhotoItemModel *photoItem in _photos) {
        [photos addObject:[photoItem.photo serializeToDictionary]];
    }
    return photos;
}

- (NSMutableArray *)serializeLastAddedPhotosToDictionary {

    NSMutableArray *photos = [NSMutableArray array];

    for (CartPhotoItemModel *photoItem in _lastAddedPhotos) {
        [photos addObject:[photoItem.photo serializeToDictionary]];
    }
    return photos;
}

- (id)init {
    if ((self = [super init]) != nil) {
        UserModel *userModel = [UserModel userModel];

        self.photos = [[[NSMutableArray alloc] init] autorelease];
        self.lastAddedPhotos = [[[NSMutableArray alloc] init] autorelease];
        self.printSize = @"4x6";
        self.email = [userModel email];
        self.firstName = [userModel firstName];
        self.newPhotoCount = 0;

        _clearWebCart = NO;
    }

    return self;
}

- (void)dealloc {
    [_store release];
    [_catalog release];
    [_photos release];
    [_printSize release];
    [_firstName release];
    [_lastName release];
    [_email release];
    [_lastAddedPhotos release];
    [super dealloc];
}

- (NSDecimalNumber *)total {
    return nil;
}

// expects photo objects
- (void)addPhotos:(NSArray *)photos {
    for (PhotoModel *photo in photos) {
        if ([self findPhotoFromId:photo.photoId] == nil) {
            [_photos addObject:[[[CartPhotoItemModel alloc] initWithPhoto:photo] autorelease]];
            [_lastAddedPhotos addObject:[[[CartPhotoItemModel alloc] initWithPhoto:photo] autorelease]];
        }
    }

    self.newPhotoCount = [photos count];

    [self sendUpdatedCartNotification];
}

- (void)addPhoto:(PhotoModel *)photo {
    if ([self findPhotoFromId:photo.photoId]) {
        return;
    }

    [_photos addObject:[[[CartPhotoItemModel alloc] initWithPhoto:photo] autorelease]];
    [_lastAddedPhotos addObject:[[[CartPhotoItemModel alloc] initWithPhoto:photo] autorelease]];

    self.newPhotoCount = 1;

    [self sendUpdatedCartNotification];
}

- (void)clearLastAddedPhotos {
    self.lastAddedPhotos = [[[NSMutableArray alloc] init] autorelease];
}


- (void)removePhotos:(NSArray *)photoIds {
    for (NSString *photoId in photoIds) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photo.photoId != %@", photoId];
        [_photos filterUsingPredicate:predicate];
    }
    [self sendUpdatedCartNotification];

}


- (void)removePhoto:(NSString *)photoId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photo.photoId != %@", photoId];
    [_photos filterUsingPredicate:predicate];

    [self sendUpdatedCartNotification];
}

- (PhotoModel *)findPhotoFromId:(NSNumber *)photoId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photo.photoId == %@", photoId];
    NSArray *results = [_photos filteredArrayUsingPredicate:predicate];

    if ([results count] == 0) {
        return nil;
    }
    PhotoModel *photo = (PhotoModel *) [results objectAtIndex:0];
    return photo;
}


- (NSDecimalNumber *)estimatedTax {
    return nil;
}

- (void)clearCart {
    self.photos = [[[NSMutableArray alloc] init] autorelease];
    self.lastAddedPhotos = [[[NSMutableArray alloc] init] autorelease];
    self.newPhotoCount = 0;

    [self sendUpdatedCartNotification];
}

- (void)clearStoreInfo {
    self.store = [[[StoreModel alloc] init] autorelease];
}

- (NSDecimalNumber *)subtotal {
    return nil;
}


+ (CartModel *)cartModel {
    if (!currentCartModel) {
        currentCartModel = [[CartModel alloc] init];
        [currentCartModel restoreCart];
    }

    return currentCartModel;
}

+ (void)setCurrentCartModel:(CartModel *)cartModel {
    if (currentCartModel != cartModel) {
        [currentCartModel release];
        currentCartModel = cartModel;
        [currentCartModel retain];
    }
}

- (void)sendUpdatedCartNotification {
    [[NSNotificationCenter defaultCenter]
            postNotificationName:@"CartUpdated"
                          object:self];

}


// only stores store for now
// called at: applicationDidEnterBackground
- (void)persistCart {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/KodakGallery-%@", documentsDirectoryPath, kCartArchivePath];

    [NSKeyedArchiver archiveRootObject:self.store toFile:fileName];

	// Ensures the cart will be cleared the next time the user enters the cart workflow even if the user terminates the app
	// directly after signout and does not re-enter the cart workflow
	[[NSUserDefaults standardUserDefaults] setBool:self.clearWebCart forKey:@"clearWebCart"];
	[[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)restoreCart {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/KodakGallery-%@", documentsDirectoryPath, kCartArchivePath];

    self.store = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
	
	self.clearWebCart = [[NSUserDefaults standardUserDefaults] boolForKey:@"clearWebCart"];
}

@end
