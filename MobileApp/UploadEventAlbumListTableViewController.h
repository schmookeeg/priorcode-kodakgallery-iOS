//
//  EventAlbumTTViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>
#import "MBProgressHUD.h"
#import "AbstractAlbumModel.h"

@interface UploadEventAlbumListTableViewController : TTTableViewController <TTModelDelegate, MBProgressHUDDelegate, UITextFieldDelegate, AlbumModelDelegate>
{
	UIView *headerView;
	UITextField *textField;
	MBProgressHUD *_hud;
	AbstractAlbumModel *_eventAlbum;
}

- (UIView *)headerView;

@property ( nonatomic, retain ) UITextField *textField;
@property ( nonatomic, retain ) AbstractAlbumModel *eventAlbum;
@property ( nonatomic, readonly ) MBProgressHUD *hud;

@end
