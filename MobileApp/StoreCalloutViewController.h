//
//  StoreCalloutViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapPointAnnotation.h"
#import "GradientButton.h"

@class LocationViewController;

@interface StoreCalloutViewController : UIViewController {
@private
    MapPointAnnotation *_annotation;
    LocationViewController *_locationViewController;
    StoreModel *_store;

    CGRect _storeSelectButtonFrame;
    CGRect _hoursFrame;
}
@property (retain, nonatomic) IBOutlet UILabel *address;
@property (retain, nonatomic) IBOutlet UILabel *storeName;
@property (retain, nonatomic) IBOutlet UITextView *phoneNumber;
@property (retain, nonatomic) IBOutlet UILabel *hours;
@property (retain, nonatomic) IBOutlet GradientButton *storeSelectButton;
@property (retain, nonatomic) MapPointAnnotation *annotation;
@property (retain, nonatomic) LocationViewController *locationViewController;
@property (retain, nonatomic) StoreModel *store;

@property (nonatomic) BOOL isTableView;

- (IBAction)storeSelected:(id)sender;
- (id)initAsTableView;
- (void)setupStore;


@end
