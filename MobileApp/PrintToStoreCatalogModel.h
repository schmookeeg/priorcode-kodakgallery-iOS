//
//  Created by jcampbell on 1/5/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AbstractModel.h"

@class PrintSKUModel;

@interface PrintToStoreCatalogModel : AbstractModel {

@private
    NSArray *_skuList;
}

@property (nonatomic, retain) NSArray* skuList;

- (PrintSKUModel *)skuWithSize:(NSString *)size finish:(NSString *)finish;
@end