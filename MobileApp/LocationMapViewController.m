//
//  LocationMapViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "LocationMapViewController.h"
#import "LocationViewController.h"
#import "StoreModel.h"

@implementation LocationMapViewController

@synthesize storeViewController;
@synthesize locationViewController = _locationViewController;

#define DEFAULT_ZOOM 15
#define ANNOTATION_ZOOM 2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		// Custom initialization

	}

	return self;
}


- (void)dealloc
{
	[_mapView release];

	[_locationViewController release];
	[storeViewController release];

	[super dealloc];

}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	_mapView.showsUserLocation = NO;
}

- (void)showLocation:(CLLocation *)location
{
	StoreCollectionModel *storeCollectionModel = self.locationViewController.storeCollectionModel;

	if ( [storeCollectionModel.stores count] > 0 )
	{
		MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance( location.coordinate, DEFAULT_ZOOM * METERS_PER_MILE, DEFAULT_ZOOM * METERS_PER_MILE );
		MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];

		[_mapView setRegion:adjustedRegion animated:YES];
		[_mapView removeAnnotations:[_mapView annotations]];

		for ( StoreModel *store in [storeCollectionModel stores] )
		{
			[self drawStore:store];
		}


	}
	else
	{
		// show error
	}
}


- (void)drawStore:(StoreModel *)store
{
	MapPointAnnotation *annotation = [[[MapPointAnnotation alloc] initWithStore:store] autorelease];
	[_mapView addAnnotation:annotation];

}

- (void)viewDidUnload
{
	[super viewDidUnload];

	[_mapView release];
	_mapView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

- (void)addStoreLocationForAnnotationView:(MKAnnotationView *)view
{
	StoreCalloutViewController *callout = [[[StoreCalloutViewController alloc] init] autorelease];
	MapPointAnnotation *annotation = callout.annotation = (MapPointAnnotation *) view.annotation;
	callout.locationViewController = self.locationViewController;

	MKCoordinateRegion currentViewRegion = MKCoordinateRegionMakeWithDistance( annotation.coordinate, _mapView.region.span.latitudeDelta, _mapView.region.span.longitudeDelta );
	MKCoordinateRegion currentAdjustedRegion = [_mapView regionThatFits:currentViewRegion];

	CGFloat newX = ( _mapView.frame.size.width / 2 ) - ( callout.view.frame.size.width / 2 );

	callout.view.frame = CGRectMake( newX, 25, callout.view.frame.size.width, callout.view.frame.size.height );

	[_mapView addSubview:[callout view]];

	// center around annotation when opening popup
	CLLocationDegrees pixelsPerDegreeLatitude = _mapView.frame.size.height / currentAdjustedRegion.span.latitudeDelta;
	CLLocationDegrees yPixelShift = callout.view.frame.size.height / 3;

	CLLocationDegrees latitudinalShift = yPixelShift / pixelsPerDegreeLatitude;
	CLLocationCoordinate2D location = { annotation.coordinate.latitude + latitudinalShift, annotation.coordinate.longitude };

	[_mapView setCenterCoordinate:location animated:YES];


	self.storeViewController = callout;

	return;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	// We must defer this method call until AFTER the didDeselectAnnotationView event is processed.  On iOS5 the didDeselectAnnotationView
	// event always arrives before this event, but the order of events appears to be switched on iOS 4.3.   So on iOS 4.3 we get the deSelect after the select
	// event so this causes us to delete the item we just added !!   
	// Pushing the message onto the event queue ensures it's processed after the deselect is processed
	[self performSelector:@selector(addStoreLocationForAnnotationView:) withObject:view afterDelay:0];
}


- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
	if ( self.storeViewController )
	{
		[self.storeViewController.view removeFromSuperview];
	}
	self.storeViewController = nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView *aView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
	if ( !aView )
	{
		aView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"] autorelease];

		aView.canShowCallout = NO;
	}

	aView.annotation = annotation;

	return aView;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	if ( self.storeViewController )
	{
		[_mapView deselectAnnotation:self.storeViewController.annotation animated:NO];
	}
}


@end
