//
//  Created by jcampbell on 1/5/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrintSKUModel.h"
#import "PrintSKUPricingModel.h"


@implementation PrintSKUModel
@synthesize border = _border;
@synthesize paperFinish = _paperFinish;
@synthesize paperSize = _paperSize;
@synthesize pricing = _pricing;
@synthesize skuId = _skuId;
@synthesize tint = _tint;
@synthesize colorMgmt = _colorMgmt;


- (void)dealloc {
    [_border release];
    [_paperFinish release];
    [_paperSize release];
    [_pricing release];
    [_skuId release];
    [_tint release];
    [_colorMgmt release];
    [super dealloc];
}

- (NSDecimalNumber *)targetPricing {
    NSPredicate *predicate = [NSPredicate
        predicateWithFormat:@"name == %@", @"Target"];
    
    NSArray *results = [_pricing filteredArrayUsingPredicate:predicate];
    
    if (results.count > 0) {
        return ((PrintSKUPricingModel *)[results objectAtIndex:0]).price;
    }

    return nil;
}

- (NSDecimalNumber *)cvsPricing {
    NSPredicate *predicate = [NSPredicate
        predicateWithFormat:@"name == %@", @"CVS"];

    NSArray *results = [_pricing filteredArrayUsingPredicate:predicate];

    if (results.count > 0) {
        return ((PrintSKUPricingModel *)[results objectAtIndex:0]).price;
    }
    
    return nil;
}

@end