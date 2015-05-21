//
//  SelectThumbsTableViewCellDelegate.h
//  MobileApp
//
//  Created by Jon Campbell on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@protocol SelectThumbsTableViewCellDelegate <TTThumbsTableViewCellDelegate>

- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo withThumbView:(TTThumbView *)thumbView;


@end
