//
//  ProductListViewController.h
//  MobileApp
//
//  Created by Darron Schall on 2/17/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@interface ProductListViewController : TTTableViewController
{
    CAGradientLayer *_gradientLayer;
}

- (id)initWithAlbumId:(NSString *)albumId photoId:(NSString *)photoId;

@end
