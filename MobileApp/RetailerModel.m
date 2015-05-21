//
//  Created by jcampbell on 1/10/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "RetailerModel.h"


@implementation RetailerModel
@synthesize logoUrl = _logoUrl;
@synthesize maxOrderAmt = _maxOrderAmt;

- (void)dealloc {
    [_logoUrl release];
    [_maxOrderAmt release];
    [super dealloc];
}
@end