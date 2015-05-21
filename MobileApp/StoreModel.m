//
//  StoreModel.m
//  MobileApp
//
//  Created by Jon Campbell on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreModel.h"
#import "RetailerModel.h"

@implementation StoreModel

@synthesize storeId = _storeId;
@synthesize address = _address;
@synthesize city = _city;
@synthesize distance = _distance;
@synthesize enabled = _enabled;
@synthesize formattedStoreHours = _formattedStoreHours;
@synthesize id = _id;
@synthesize name = _name;
@synthesize phoneNumber = _phoneNumber;
@synthesize postalCode = _postalCode;
@synthesize printSizes = _printSizes;
@synthesize retailer = _retailer;
@synthesize retailerId = _retailerId;
@synthesize serviceTime = _serviceTime;
@synthesize state = _state;
@synthesize storeDays = _storeDays;
@synthesize storeHours = _storeHours;
@synthesize longitude = _longitude;
@synthesize latitude = _latitude;

- (BOOL)hasPrintSize:(NSString *)size
{
	for ( NSString *currentSize in self.printSizes )
	{
		if ( [size isEqualToString:currentSize] )
		{
			return YES;
		}
	}

	return NO;
}

- (CLLocationCoordinate2D)coordinate
{
	return CLLocationCoordinate2DMake( [self.latitude doubleValue], [self.longitude doubleValue] );
}

- (NSDictionary *)serializeToDictionary
{
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"storeId", self.storeId,
			@"address", self.address,
			@"city", self.city,
			@"state", self.state,
			@"name", self.name,
			@"formattedStoreHours", self.formattedStoreHours,
			@"phoneNumber", self.phoneNumber,
			@"postalCode", self.postalCode,
			@"retailerId", self.retailerId,
			@"state", self.state,
			@"latitude", self.latitude,
			@"longitude", self.longitude,
			nil];
}

#pragma mark NSCoding

#define kStoreIdKey @"storeId"
#define kAddressKey @"address"
#define kCityKey @"city"
#define kStateKey @"state"
#define kNameKey @"name"
#define kFormattedStoreHoursKey @"formattedStoreHours"
#define kPhoneNumberKey @"phoneNumber"
#define kPostalCodeKey @"postalCode"
#define kRetailerIdKey @"retailerId"
#define kStateKey @"state"
#define kLatitudeKey @"latitude"
#define kLongitudeKey @"longitude"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	/*
[encoder encodeObject:_title forKey:kTitleKey];
   [encoder encodeFloat:_rating forKey:kRatingKey];
*/

	[aCoder encodeObject:_storeId forKey:kStoreIdKey];
	[aCoder encodeObject:_address forKey:kAddressKey];
	[aCoder encodeObject:_city forKey:kCityKey];
	[aCoder encodeObject:_state forKey:kStateKey];
	[aCoder encodeObject:_name forKey:kNameKey];
	[aCoder encodeObject:_formattedStoreHours forKey:kFormattedStoreHoursKey];
	[aCoder encodeObject:_phoneNumber forKey:kPhoneNumberKey];
	[aCoder encodeObject:_postalCode forKey:kPostalCodeKey];
	[aCoder encodeObject:_retailerId forKey:kRetailerIdKey];
	[aCoder encodeObject:_state forKey:kStateKey];
	[aCoder encodeObject:_latitude forKey:kLatitudeKey];
	[aCoder encodeObject:_longitude forKey:kLongitudeKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [self init];

	if ( self )
	{
		self.storeId = [aDecoder decodeObjectForKey:kStoreIdKey];
		self.address = [aDecoder decodeObjectForKey:kAddressKey];
		self.city = [aDecoder decodeObjectForKey:kCityKey];
		self.state = [aDecoder decodeObjectForKey:kStateKey];
		self.name = [aDecoder decodeObjectForKey:kNameKey];
		self.formattedStoreHours = [aDecoder decodeObjectForKey:kFormattedStoreHoursKey];
		self.phoneNumber = [aDecoder decodeObjectForKey:kPhoneNumberKey];
		self.postalCode = [aDecoder decodeObjectForKey:kPostalCodeKey];
		self.retailerId = [aDecoder decodeObjectForKey:kRetailerIdKey];
		self.state = [aDecoder decodeObjectForKey:kStateKey];
		self.latitude = [aDecoder decodeObjectForKey:kLatitudeKey];
		self.longitude = [aDecoder decodeObjectForKey:kLongitudeKey];
	}

	return self;
}

- (void)dealloc
{
	[_storeId release];
	[_address release];
	[_city release];
	[_distance release];
	[_formattedStoreHours release];
	[_id release];
	[_name release];
	[_phoneNumber release];
	[_postalCode release];
	[_printSizes release];
	[_retailer release];
	[_retailerId release];
	[_serviceTime release];
	[_state release];
	[_storeDays release];
	[_storeHours release];
	[_longitude release];
	[_latitude release];

	[super dealloc];
}


@end
