//
//  Created by darron on 2/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SPMProductConfiguration.h"

@implementation SPMProductConfiguration

@synthesize product = _product;
@synthesize sku = _sku;
@synthesize layout = _layout;

#pragma mark Init / Dealloc

- (id)init
{
    self = [super init];
	if ( self )
	{
        //_layouts = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSString *)description 
{
	return [NSString stringWithFormat:@"<%@:%p Product: %@\n SKU: %@\n Layout: %@", NSStringFromClass([self class]), (void *) self, self.product, self.sku, self.layout];
}

- (void)dealloc
{
	[_layout release];
	_layout = nil;

    [_product release];
	_product = nil;
    
    [_sku release];
	_sku = nil;

	[super dealloc];
}

@end