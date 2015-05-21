//
//  Created by jcampbell on 1/5/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrintToStoreCatalogModel.h"
#import "PrintSKUModel.h"


@implementation PrintToStoreCatalogModel
@synthesize skuList = _skuList;

- (NSString *)url {
    return kServicePrintToStoreCatalog;
}

- (PrintSKUModel *)skuWithSize:(NSString *)size finish:(NSString *)finish {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"paperSize == %@ AND paperFinish == %@"];

    NSArray *results = [_skuList filteredArrayUsingPredicate:predicate];

    if (results.count > 0) {
        return (PrintSKUModel *) [results objectAtIndex:0];
    }

    return nil;
}

- (void)dealloc {
    [_skuList release];
    [super dealloc];
}
@end