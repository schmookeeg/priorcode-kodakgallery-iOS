//
//  Created by jcampbell on 1/5/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AbstractModel.h"


@interface PrintSKUPricingModel : AbstractModel {

@private
    NSString *_name;
    NSDecimalNumber *_price;
    NSDecimalNumber *_salePrice;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDecimalNumber *price;
@property (nonatomic, retain) NSDecimalNumber *salePrice;

@end