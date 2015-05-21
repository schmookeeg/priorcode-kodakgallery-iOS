//
//  PhotoCommentsListTableViewController.h
//  MobileApp
//
//  Created by mikeb on 6/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "PhotoModel.h"
#import "PhotoCommentsListModel.h"
#import "AlbumPicturesAnnotationsModel.h"
#import "MBProgressHUD.h"

@interface PhotoCommentsListTableViewController : TTTableViewController <PhotoCommentsListModelDelegate, AlbumPicturesAnnotationsModelDelegate, TTModelDelegate, UITextFieldDelegate, TTPostControllerDelegate, UITextViewDelegate>
{
	UIBarButtonItem *_likeButton;
	UIView *headerView;
	UITextField *headerTextField;
	NSString *_photoId;
	TTPostController *postController;
	AlbumPicturesAnnotationsModel *_albumAnnotationsModel;
	PhotoCommentsListModel *_photoCommentsModel;
	BOOL _enterCommentPostMode;
	MBProgressHUD *_hud;
}

@property ( nonatomic, retain ) NSString *photoId;
@property ( nonatomic, retain ) PhotoModel *photoModel;
@property ( nonatomic, retain ) PhotoCommentsListModel *photoCommentsModel;
@property ( nonatomic, retain ) AlbumPicturesAnnotationsModel *albumAnnotationsModel;

- (UIView *)headerView;

- (id)initWithPhotoId:(NSString *)photoId;

- (id)initWithPhotoIdPost:(NSString *)photoId;

- (void)done;

@end
