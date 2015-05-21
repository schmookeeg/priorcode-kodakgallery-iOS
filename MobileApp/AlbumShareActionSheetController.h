//
//  AlbumShareActionSheetController.h
//  MobileApp
//
//  Created by Darron Schall on 11/18/11.
//  Copyright (c) 2011 Universal Mind, Inc. All rights reserved.
//

#import "ShareActionSheetController.h"
#import "AbstractAlbumModel.h"
#import "AlbumModelDelegate.h"

@interface AlbumShareActionSheetController : ShareActionSheetController <AlbumModelDelegate>
{
	int _shareIndex;
    NSString *_shareTitle;
}

- (id)initWithDelegate:(id <ShareActionSheetControllerDelegate>)delegate album:(AbstractAlbumModel *)album;
- (void)showOptions;

@end
