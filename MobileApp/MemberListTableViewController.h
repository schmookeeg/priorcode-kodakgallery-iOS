//
//  MemberListTableViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "AbstractAlbumModel.h"
#import "ShareActionSheetController.h"
#import "ThumbViewController.h"

@interface MemberListTableViewController : TTTableViewController <TTModelDelegate, ShareActionSheetControllerDelegate>

- (id)initWithEventAlbum:(AbstractAlbumModel *)eventAlbum;

- (void)done;

@property ( nonatomic, retain ) ShareActionSheetController *shareActionController;
@property ( nonatomic, retain ) ThumbViewController *thumbViewController;

@end
