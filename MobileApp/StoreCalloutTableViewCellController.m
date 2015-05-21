//
//  StoreCalloutTableViewCellController.m
//  MobileApp
//
//  Created by Jon Campbell on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoreCalloutTableViewCellController.h"
#import "StoreCalloutViewController.h"
#import "StoreModel.h"
#import "LocationViewController.h"

@implementation StoreCalloutTableViewCellController

@synthesize storeCallout = _storeCallout;
@synthesize locationViewController = _locationViewController;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.storeCallout = [[[StoreCalloutViewController alloc] initAsTableView] autorelease];
        self.storeCallout.locationViewController = self.locationViewController;
        [self.contentView addSubview:self.storeCallout.view];
    }
    
    return self;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_storeCallout release];
    [_locationViewController release];
    [super dealloc];
}

- (void)setStore:(StoreModel *)store {
    self.storeCallout.store = store;

}

- (StoreModel *)store {
    return self.storeCallout.store;

}


@end
