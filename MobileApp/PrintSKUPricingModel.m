//
//  Created by jcampbell on 1/5/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrintSKUPricingModel.h"


@implementation PrintSKUPricingModel
@synthesize name = _name;
@synthesize price = _price;
@synthesize salePrice = _salePrice;


- (void)dealloc
{
    [_name release];
	[_price release];
	[_salePrice release];
	
    [super dealloc];
}
@end