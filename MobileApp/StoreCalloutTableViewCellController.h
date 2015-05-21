//
//  StoreCalloutTableViewCellController.h
//  MobileApp
//
//  Created by Jon Campbell on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreModel;
@class StoreCalloutViewController;
@class LocationViewController;

@interface StoreCalloutTableViewCellController : UITableViewCell {
@private
    StoreCalloutViewController *_storeCallout;
    LocationViewController *_locationViewController;
}
- (void)setStore:(StoreModel*)store;
- (StoreModel*)store;

@property (nonatomic, retain) StoreCalloutViewController *storeCallout;

@property(nonatomic, retain) LocationViewController *locationViewController;
@end
