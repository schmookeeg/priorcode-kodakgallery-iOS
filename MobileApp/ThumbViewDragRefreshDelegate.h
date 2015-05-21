//
//  ThumbViewDragRefreshDelegate.h
//  MobileApp
//
//  Created by P. Traeg on 9/2/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "Three20UI/TTTableViewDelegate.h"

@class TTTableHeaderDragRefreshView;
@protocol TTModel;

/**
 * Cloned from TTTableHeaderDragRefreshDelegate but changed to inherit from TTTableViewDelegate instead
 */
@interface ThumbViewDragRefreshDelegate : TTTableViewDelegate
{
	TTTableHeaderDragRefreshView *_headerView;
	id <TTModel> _model;
}

@property ( nonatomic, retain ) TTTableHeaderDragRefreshView *headerView;

@end
