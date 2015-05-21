//
//  StoreModel.h
//  MobileApp
//
//  Created by Jon Campbell on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AbstractModel.h"

@class RetailerModel;

@interface StoreModel : AbstractModel<NSCoding>
{
    
}


- (BOOL) hasPrintSize: (NSString*)size;

- (CLLocationCoordinate2D)coordinate;
- (NSDictionary *)serializeToDictionary;


@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* address;
@property (nonatomic, retain) NSString* city;
@property (nonatomic, retain) NSString* state;
@property (nonatomic, retain) NSString* postalCode;
@property (nonatomic, retain) NSString* phoneNumber;
@property (nonatomic, retain) NSString* storeHours;
@property (nonatomic, retain) NSString* serviceTime;
@property (nonatomic, retain) NSNumber* distance;
@property (nonatomic, retain) NSArray* printSizes;
@property (nonatomic, retain) NSArray* formattedStoreHours;
@property (nonatomic, retain) NSString* storeDays;
@property (nonatomic, retain) NSString* retailerId;
@property (nonatomic, retain) NSString* storeId;
@property (nonatomic, retain) RetailerModel* retailer;
@property (nonatomic) BOOL enabled;
@property (nonatomic, retain) NSNumber* longitude;
@property (nonatomic, retain) NSNumber* latitude;

@end
