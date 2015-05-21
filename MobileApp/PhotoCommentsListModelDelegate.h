//
//  PhotoCommentsListModelDelegate.h
//  MobileApp
//
//  Created by mikeb on 6/22/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractModelDelegate.h"

@class PhotoCommentsListModel;

@protocol PhotoCommentsListModelDelegate <AbstractModelDelegate>

@optional
- (void)didAddCommentSucceed:(PhotoCommentsListModel *)model;

- (void)didAddCommentFail:(PhotoCommentsListModel *)model  error:(NSError *)error;;

@end

