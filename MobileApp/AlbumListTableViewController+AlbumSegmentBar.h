//
//  AlbumListTableViewController+AlbumSegmentBar.h
//  MobileApp
//
//  Created by Jon Campbell on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumListTableViewController.h"

@interface AlbumListTableViewController (AlbumSegmentBar)

- (void)selectTabFromAlbumType:(NSNumber *)albumType;


- (void)setupAlbumNavigation;


- (IBAction)selectedSegmentValue: (id)sender;

@end
