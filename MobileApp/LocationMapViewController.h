//
//  LocationMapViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import <MapKit/MapKit.h>

#import "StoreCalloutViewController.h"

@class LocationViewController;


#define METERS_PER_MILE 1609.344

@interface LocationMapViewController : UIViewController <MKMapViewDelegate>
{
	IBOutlet MKMapView *_mapView;
	LocationViewController *_locationViewController;
}

@property ( nonatomic, retain ) StoreCalloutViewController *storeViewController;
@property ( nonatomic, retain ) LocationViewController *locationViewController;

- (void)drawStore:(StoreModel *)store;

- (void)showLocation:(CLLocation *)location;

@end
