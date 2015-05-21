//
//  LocationViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CoreGeoLocation.h"
#import "MBProgressHUD.h"
#import "LocationMapViewController.h"
#import "LocationTableViewController.h"
#import "StoreCollectionModel.h"


@interface LocationViewController : UIViewController <CLLocationManagerDelegate, MBProgressHUDDelegate, UISearchBarDelegate, CGLGeoManagerDelegate> {
    

@private
    IBOutlet UISearchBar *_searchBar;
    IBOutlet UIToolbar *_locationButton;
    CLLocationManager *_locationManager;
    MBProgressHUD *_hud;
    StoreCollectionModel *_storeCollectionModel;
    NSString *_currentZipCode;
}

- (IBAction)viewToggled:(id)sender;
- (IBAction)findCurrentLocation:(id)sender;

- (void)showLocation:(CLLocation *)location;
- (void)stopUpdatingLocation;

- (void)cancel;
- (void)selectStore:(StoreModel*)store;


@property (retain, nonatomic) IBOutlet UIView *middleView;
@property (retain, nonatomic) LocationMapViewController *mapViewController;
@property (retain, nonatomic) LocationTableViewController *tableViewController;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property ( nonatomic, readonly ) MBProgressHUD *hud;
@property (retain, nonatomic) IBOutlet UISegmentedControl *buttonBar;
@property (retain, nonatomic) StoreCollectionModel *storeCollectionModel;
@property (retain, nonatomic) NSString *currentZipCode;

- (void)showNoStoresError;


@end
