//
//  AlbumListTableViewController+AlbumSegmentBar.m
//  MobileApp
//
//  Created by Jon Campbell on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumListDataSource.h"
#import "AlbumListTableViewController+AlbumSegmentBar.h"

CGFloat headerBarHeight = 25.0;

@implementation AlbumListTableViewController (AlbumSegmentBar)

- (void)setupAlbumNavigation {
    CGRect frame = [self rectForHeaderView];
    frame.size.height += 5;

	// Draw gradient behind filterbar buttons
	CGRect backFrame = CGRectMake(0, 0, self.view.bounds.size.width, frame.size.height + 10);
    UIView *filterBarBackground = [[[UIView alloc] initWithFrame:backFrame] autorelease];
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
	[gradientLayer setBounds:[filterBarBackground bounds]];
	[gradientLayer setPosition:	CGPointMake( [filterBarBackground bounds].size.width / 2, [filterBarBackground bounds].size.height / 2 )];

	[[filterBarBackground layer] insertSublayer:gradientLayer atIndex:0];
	UIColor *backColor1 = [UIColor colorWithRed:117.0 / 255.0 green:117.0 / 255.0 blue:117.0 / 255.0 alpha:1.0];
	UIColor *backColor2 = [UIColor colorWithRed:59.0 / 255.0 green:59.0 / 255.0 blue:59.0 / 255.0 alpha:1.0];
	UIColor *backColor3 = [UIColor colorWithRed:44.0 / 255.0 green:44.0 / 255.0 blue:44.0 / 255.0 alpha:1.0];
	UIColor *backColor4 = [UIColor colorWithRed:41.0 / 255.0 green:41.0 / 255.0 blue:41.0 / 255.0 alpha:1.0];
	[gradientLayer setColors:
		[NSArray arrayWithObjects:
			(id) [backColor1 CGColor],
			(id) [backColor2 CGColor],
			(id) [backColor3 CGColor],
			(id) [backColor4 CGColor], nil]];
	[gradientLayer setLocations:[NSArray arrayWithObjects:
								 [NSNumber numberWithFloat:0.0], 
								 [NSNumber numberWithFloat:0.5], 
								 [NSNumber numberWithFloat:0.5], 
								 [NSNumber numberWithFloat:1.0], 
								 nil]];
	[gradientLayer release];

    UISegmentedControl *controlView = [[UISegmentedControl alloc] initWithFrame:frame];

    controlView.tintColor = [UIColor darkGrayColor];

    [controlView insertSegmentWithTitle:@"All" atIndex:0 animated:NO];
    [controlView insertSegmentWithTitle:@"My" atIndex:1 animated:NO];
    [controlView insertSegmentWithTitle:@"Friends'" atIndex:2 animated:NO];
    [controlView insertSegmentWithTitle:@"Group" atIndex:3 animated:NO];

    [controlView addTarget:self
                    action:@selector(selectedSegmentValue:)
          forControlEvents:UIControlEventValueChanged];

    controlView.selectedSegmentIndex = 0;
    controlView.segmentedControlStyle = UISegmentedControlStyleBar;

    self.view.backgroundColor = backColor1;
    controlView.alpha = .9;

    self.headerAlbumOptions = controlView;
    [filterBarBackground addSubview:controlView];
    [self.view addSubview:filterBarBackground];

    UIView *border = [[[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height + 10, self.tableView.bounds.size.width, 1)] autorelease];
    border.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:border];

    [controlView release];
}

- (IBAction)selectedSegmentValue:(id)sender {
    int index = self.headerAlbumOptions.selectedSegmentIndex;
    NSNumber *albumType;
    switch (index) {
        case 3:
            albumType = [NSNumber numberWithInt:kEventAlbumType];
            [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Album List:Group Album"];
            break;
        case 1:
            albumType = [NSNumber numberWithInt:kMyAlbumType];
            [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Album List:My Album"];
            break;
        case 2:
            albumType = [NSNumber numberWithInt:kFriendAlbumType];
            [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Album List:Friend Album"];
            break;
        case 0:
        default:
            albumType = [NSNumber numberWithInt:kAllAlbumType];
            [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Album List:All Albums"];
    }

    [self selectTabFromAlbumType:albumType];
}

- (CGRect)rectForHeaderView {
    return CGRectMake(10.0, 5.0, self.tableView.bounds.size.width - 20.0, headerBarHeight);
}

- (void)selectTabFromAlbumType:(NSNumber *)albumType {
    int albumTypeIntValue = [albumType intValue];

    // Filter the data source to display the albums of type albumType
    AlbumListDataSource *dataSource = (AlbumListDataSource *) self.dataSource;
    if (![dataSource.filterAlbumType isEqualToNumber:albumType]) {
        // TRICKY: If we change tabs and the filter changes, the showEmpty
        // method is not automatically called again if we're currently showing
        // the empty screen... so make sure we hide the empty screen if we're
        // showing it so that if the new filter is empty the showEmpty call
        // will display the right empty screen for the album type.
        if (_flags.isShowingEmpty) {
            [self showEmpty:NO];
            _flags.isShowingEmpty = NO;
        }

        dataSource.filterAlbumType = albumType;

        // Save album type and use in search functionality.
        [[NSUserDefaults standardUserDefaults] setObject:dataSource.filterAlbumType forKey:@"FILTERKEY"];

        [self refresh];
    }

    // STABTWO-1370 - Hide the add album button when viewing friend's albums.
    if (([[[[[AbstractAlbumModel albumClassFromType:albumTypeIntValue] alloc] init] autorelease] enabledOptions] & kAlbumTypeOptionEnableUpload) == kAlbumTypeOptionEnableUpload) {
        self.navigationItem.rightBarButtonItem = self.addAlbumButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


@end
