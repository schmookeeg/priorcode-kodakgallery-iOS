//
//  LocationViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreGeoLocation.h"
#import "LocationViewController.h"
#import "CartModel.h"

@implementation LocationViewController

@synthesize middleView;
@synthesize mapViewController;
@synthesize locationManager = _locationManager;
@synthesize buttonBar = _buttonBar;
@synthesize tableViewController;
@synthesize storeCollectionModel = _storeCollectionModel;
@synthesize currentZipCode = _currentZipCode;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.storeCollectionModel = [[[StoreCollectionModel alloc] init] autorelease];

        CGLGeoDataProviderYahoo *yahooDataProvider = [[CGLGeoDataProviderYahoo alloc] init];
        [yahooDataProvider setApplicationID:kYahooApplicationID];
        [[CGLGeoManager sharedManager] setDataProvider:yahooDataProvider];
        [yahooDataProvider release];
        [[CGLGeoManager sharedManager] setDelegate:self];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.hud.labelText = @"Loading...";

    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;


    self.title = @"Select Store Location";

    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)] autorelease];

    self.navigationItem.leftBarButtonItem = cancelButton;


    [self findCurrentLocation:nil];


    self.mapViewController = [[[LocationMapViewController alloc] init] autorelease];;
    [self.middleView addSubview:self.mapViewController.view];

    [self.buttonBar addTarget:self
                       action:@selector(viewToggled:)
             forControlEvents:UIControlEventValueChanged];


    self.mapViewController.locationViewController = self;

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Prints:Cart:StoreLocation:Map"];

}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.hud show:YES];

    NSString *searchValue = [searchBar text];

    [[CGLGeoManager sharedManager] determineGeographicalNameForAddress:searchValue];
    [searchBar resignFirstResponder];
}


- (void)geoManager:(CGLGeoManager *)inGeoManager determinedLocation:(CGLGeoLocation *)inLocation forRequest:(CGLGeoRequest *)inRequest {
    if (inLocation) {
        self.currentZipCode = inLocation.zip;
        [self showLocation:inLocation.coreLocation];
        _searchBar.text = self.currentZipCode;
    } else {
        [self showNoStoresError];
    }
}

- (void)showNoStoresError {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"No Results Found" message:@"No stores we found at the location you entered. Please try another location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
    [self.hud hide:YES];
}

- (IBAction)findCurrentLocation:(id)sender {
    [self.hud show:YES];

    if (sender != nil && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self.hud hide:YES];
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Turn on Location Services" message:@"From the home screen, go to Settings > Location Services > Kodak Gallery to enable this feature." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [alert show];
    } else {
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        [self performSelector:@selector(stopUpdatingLocation) withObject:nil afterDelay:20];
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;

    [[CGLGeoManager sharedManager] determineGeographicalNameForLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation];

        [self.hud hide:YES];
    }
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;

    if (_hud) {
        [self.hud hide:YES];
    }

}

- (void)cancel {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)selectStore:(StoreModel *)store {
    [[CartModel cartModel] setStore:store];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload {
    [self setMiddleView:nil];

    [_searchBar release];
    _searchBar = nil;
    [_locationButton release];
    _locationButton = nil;

    self.locationManager = nil;
    self.buttonBar = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [_hud release];
    _hud = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark MBProgressHUD
- (void)hudWasHidden {
    TT_RELEASE_SAFELY(_hud)
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _hud.delegate = self;
        _hud.removeFromSuperViewOnHide = YES;
        [self.navigationController.view addSubview:_hud];
    }

    return _hud;
}


- (void)dealloc {
    self.tableViewController = nil;
    self.mapViewController = nil;
    self.buttonBar = nil;

    [_searchBar release];
    [_locationButton release];
    [_locationManager release];
    [_hud release];

    [middleView release];

    [_storeCollectionModel release];
    [_currentZipCode release];
    [super dealloc];
}

- (void)showLocation:(CLLocation *)location {

    DidLoadObjectsBlock didLoadObjectBlock = ^(RKObjectLoader *objectLoader, NSArray *objects) {
        if (self.storeCollectionModel.stores.count > 0) {
            [self.mapViewController showLocation:location];
            [((UITableView *) self.tableViewController.view) reloadData];
            [self.hud hide:YES];
        } else {
            [self showNoStoresError];
        }
    };
    self.storeCollectionModel.postalCode = self.currentZipCode;
    [self.storeCollectionModel fetchWithDidLoadObjectsBlock:didLoadObjectBlock];
}

- (IBAction)viewToggled:(id)sender {
    NSInteger index = self.buttonBar.selectedSegmentIndex;
    if (index == 0) {
        // selected map

        self.mapViewController.view.hidden = NO;
        self.tableViewController.view.hidden = YES;
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Prints:Cart:StoreLocation:Map"];

    } else if (index == 1) {
        // selected table

        if (!self.tableViewController) {
            self.tableViewController = [[[LocationTableViewController alloc] init] autorelease];

            self.tableViewController.locationViewController = self;

            self.tableViewController.view.frame = CGRectMake(0, 0, self.middleView.frame.size.width, self.middleView.frame.size.height);

            [self.middleView addSubview:self.tableViewController.view];
        }

        self.mapViewController.view.hidden = YES;
        self.tableViewController.view.hidden = NO;
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Prints:Cart:StoreLocation:List"];

    }
}

@end
