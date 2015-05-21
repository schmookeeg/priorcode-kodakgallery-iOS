//
//  Created by jcampbell on 1/10/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AbstractModel.h"


@interface RetailerModel : AbstractModel {

@private
    NSString *_logoUrl;
    NSNumber *_maxOrderAmt;
}

@property (nonatomic, retain) NSString* logoUrl;
@property (nonatomic, retain) NSNumber* maxOrderAmt;

@end