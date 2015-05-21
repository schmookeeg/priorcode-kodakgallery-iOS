//
//  Created by jcampbell on 1/31/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "SelectThumbsTableViewCellDelegate.h"

@interface SelectThumbsTableViewCell : TTThumbsTableViewCell {

}

@property (nonatomic, assign) id<SelectThumbsTableViewCellDelegate> delegate;

@end