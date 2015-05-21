//
//  StoreCalloutViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StoreCalloutViewController.h"
#import "StoreModel.h"
#import "LocationViewController.h"

@implementation StoreCalloutViewController
@synthesize address;
@synthesize storeName;
@synthesize phoneNumber;
@synthesize hours;
@synthesize isTableView;
@synthesize storeSelectButton;
@synthesize locationViewController = _locationViewController;

- (id)initAsTableView {
    self.isTableView = YES;
    self = [super init];

    return self;
}

- (void)setupStore {
    StoreModel *store = self.store;

    self.address.text = [NSString stringWithFormat:@"%@\n%@, %@ %@", store.address, store.city, store.state, store.postalCode];
    self.storeName.text = [[store.name componentsSeparatedByString:@" "] objectAtIndex:0];
    self.phoneNumber.text = store.phoneNumber;
    if (store.formattedStoreHours.count > 0) {
        NSString *storeHours = [NSString stringWithFormat:@"Open: \t%@", [store.formattedStoreHours componentsJoinedByString:@"\n"]];
        self.hours.text = storeHours;
    }

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization    

        self.view.userInteractionEnabled = YES;
        self.view.exclusiveTouch = YES;
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

    if (_storeSelectButtonFrame.origin.y == 0) {
        _storeSelectButtonFrame = self.storeSelectButton.frame;
        _hoursFrame = self.hours.frame;
    }

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (!self.isTableView) {
        self.view.layer.cornerRadius = 10.0;
        self.view.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.view.layer.borderWidth = 3;
        self.view.layer.shadowColor = [[UIColor grayColor] CGColor];
        self.view.layer.shadowOffset = CGSizeMake(2, 2);
        self.view.layer.shadowOpacity = 0.85;
        self.view.layer.shadowRadius = 2.0;

        UITapGestureRecognizer *singleFingerTap = [[[UITapGestureRecognizer alloc]
                initWithTarget:nil action:@selector(tapped:)] autorelease];

        [self.view addGestureRecognizer:singleFingerTap];
    } else {
        UIColor *white = [UIColor whiteColor];
        UIColor *black = [UIColor blackColor];

        self.address.textColor =
                self.storeName.textColor =
                        self.phoneNumber.textColor =
                                self.hours.textColor = black;

        self.view.backgroundColor = white;

        self.storeSelectButton.frame = CGRectMake(_storeSelectButtonFrame.origin.x + 40, _storeSelectButtonFrame.origin.y, _storeSelectButtonFrame.size.width, _storeSelectButtonFrame.size.height);
        self.hours.frame = CGRectMake(_hoursFrame.origin.x + 40, _hoursFrame.origin.y, _hoursFrame.size.width, _hoursFrame.size.height);

        [self setupStore];
    }


    UIColor *highColor = [UIColor colorWithRed:0.10 green:0.40 blue:1.00 alpha:1.0];
    UIColor *lowColor = [UIColor colorWithRed:0.24 green:0.49 blue:1.00 alpha:1.0];

    [self.storeSelectButton setHighColor:highColor];
    [self.storeSelectButton setLowColor:lowColor];
    self.storeSelectButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.storeSelectButton.layer.borderWidth = 1;
}

- (void)viewDidUnload {
    [self setAddress:nil];
    [self setStoreName:nil];
    [self setPhoneNumber:nil];
    [self setHours:nil];
    [self setAnnotation:nil];
    [self setStore:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [address release];
    [storeName release];
    [phoneNumber release];
    [hours release];
    [_annotation release];
    [_store release];
    [storeSelectButton release];
    [_locationViewController release];
    [super dealloc];
}

- (MapPointAnnotation *)annotation {
    return _annotation;

}

- (void)setAnnotation:(MapPointAnnotation *)anAnnotation {
    [_annotation release];
    _annotation = anAnnotation;
    [_annotation retain];

    self.store = _annotation.storeModel;
}

- (StoreModel *)store {
    return _store;

}

- (void)setStore:(StoreModel *)aStore {
    [_store release];
    _store = aStore;
    [_store retain];

    [self setupStore];
}

- (IBAction)storeSelected:(id)sender {
    if (self.isTableView) {
        UITableView *tableView = self.locationViewController.tableViewController.tableView;

        UIButton *button = sender;
        UITableViewCell *cell = (UITableViewCell *) button.superview.superview.superview;
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];

        [self.locationViewController.tableViewController tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else {
        [self.locationViewController selectStore:self.store];
    }
}

// look at LocationTableViewController didSelectRow for selected table views

@end
