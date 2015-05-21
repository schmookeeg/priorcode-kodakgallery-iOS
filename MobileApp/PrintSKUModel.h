//
//  Created by jcampbell on 1/5/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AbstractModel.h"

@interface PrintSKUModel : AbstractModel {

@private
    NSString *_border;
    NSString *_paperFinish;
    NSString *_paperSize;
    NSArray *_pricing;
    NSString *_skuId;
    NSString *_tint;
    NSString *_colorMgmt;
}

- (NSDecimalNumber *)targetPricing;
- (NSDecimalNumber *)cvsPricing;

@property (nonatomic, retain) NSString *skuId;
@property (nonatomic, retain) NSString *paperSize;
@property (nonatomic, retain) NSString *colorMgmt;
@property (nonatomic, retain) NSString *paperFinish;
@property (nonatomic, retain) NSString *border;
@property (nonatomic, retain) NSString *tint;
@property (nonatomic, retain) NSArray *pricing;

@end