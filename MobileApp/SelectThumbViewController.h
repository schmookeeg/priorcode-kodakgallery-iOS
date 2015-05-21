//
//  SelectThumbViewController.h
//  MobileApp
//
//  Created by Jon Campbell on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbViewController.h"

@protocol SelectThumbsTableViewCellDelegate;
@protocol SelectPhotosViewControllerDelegate;

@interface SelectThumbViewController : ThumbViewController {

@private
    NSMutableArray *_selectedPhotos;
    id <SelectPhotosViewControllerDelegate> _parentControllerDelegate;
    BOOL _navigationMode;
    NSMutableArray *_selectedThumbViews;
}

@property (nonatomic, retain) NSMutableArray *selectedPhotos;
@property (nonatomic, retain) NSMutableArray *selectedThumbViews;

@property ( nonatomic, assign ) BOOL allowMultiplePhotoSelection;
@property ( nonatomic, assign ) id<SelectPhotosViewControllerDelegate> selectPhotosDelegate;
@property (nonatomic) BOOL navigationMode;

@property(nonatomic, retain) UIBarButtonItem *selectAllButton;

- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo withThumbView:(TTThumbView*)thumbView;
- (void)initToolBar;
- (void)doneAction;
- (void)cancel;
- (void)selectAll:(id)sender;


@end

