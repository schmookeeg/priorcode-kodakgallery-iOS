//
//  LocationTableViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocationViewController;

@interface LocationTableViewController : UITableViewController {

@private
    LocationViewController *_locationViewController;
}

@property(nonatomic, retain) LocationViewController *locationViewController;


@end
