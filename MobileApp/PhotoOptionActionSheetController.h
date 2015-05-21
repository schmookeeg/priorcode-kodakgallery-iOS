//
//  PhotoShareActionSheetController.h
//  MobileApp
//
//  Created by Darron Schall on 11/18/11.
//  Copyright (c) 2011 Universal Mind, Inc. All rights reserved.
//

#import "ShareActionSheetController.h"
#import "PhotoModel.h"
#import "AbstractAlbumModel.h"

@class PrintsAddedModalAlertView;
@class AnonymousSignInModalAlertView;

@interface PhotoOptionActionSheetController : ShareActionSheetController <PhotoModelDelegate>
{
	BOOL _allowDownload;
    PrintsAddedModalAlertView *_printsAddedModalAlertView;
}

@property ( nonatomic, retain ) AbstractAlbumModel *album;
@property ( nonatomic, retain ) PrintsAddedModalAlertView *printsAddedModalAlertView;
@property(nonatomic, retain) AnonymousSignInModalAlertView *signInAlertView;

- (id)initWithDelegate:(id <ShareActionSheetControllerDelegate>)delegate album:(AbstractAlbumModel *)album photo:(PhotoModel *)photo allowDownload:(BOOL)allowDownload;

- (void)downloadToPhone;
- (void)buyPrints;
- (void)createPhotoGift;
- (void)showDownloadDisabledAlert;

@end
