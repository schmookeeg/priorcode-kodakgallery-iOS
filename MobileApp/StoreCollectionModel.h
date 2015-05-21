//
//  Created by jcampbell on 1/10/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AbstractModel.h"


@interface StoreCollectionModel : AbstractModel {

@private
    NSArray *_stores;
    NSString *_postalCode;
    NSNumber *_distance;
}

@property (nonatomic, retain) NSArray* stores;
@property (nonatomic, retain) NSString* postalCode;
@property (nonatomic, retain) NSNumber* distance;


@end