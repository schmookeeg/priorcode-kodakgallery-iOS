//
//  Created by jcampbell on 1/10/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "StoreCollectionModel.h"


@implementation StoreCollectionModel
@synthesize stores = _stores;
@synthesize postalCode = _postalCode;
@synthesize distance = _distance;

- (id)init
{
	self = [super init];

	if ( self )
	{
		self.distance = [NSNumber numberWithInt:15];
	}

	return self;
}

- (NSString *)url
{
	return [NSString stringWithFormat:kServicePrintToStoreStoreList, self.postalCode, self.distance];
}

- (void)dealloc
{
	[_stores release];
	[_postalCode release];
	[_distance release];

	[super dealloc];
}
@end