//
//  Created by darron on 2/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SPMProduct.h"
#import "SPMSKU.h"
#import "SPMLayout.h"
#import "BulkPrice.h"
#import "Page.h"

@interface SPMProductConfiguration : NSObject

@property ( nonatomic, retain ) SPMProduct *product;

@property ( nonatomic, retain ) SPMSKU *sku;

/**
 * The layout to use. One of the instances from the sku.layouts array
 */
@property ( nonatomic, retain ) SPMLayout *layout;

@end