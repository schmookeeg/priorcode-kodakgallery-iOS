//
//  AbstractModelProtocol.h
//  MobileApp
//
//  Created by Jon Campbell on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class AbstractModel;

@protocol AbstractModelDelegate <NSObject>

@optional

- (void)didModelLoad:(AbstractModel *)model;

- (void)didModelLoadFail:(AbstractModel *)model withError:(NSError *)error;

- (void)didModelChange:(AbstractModel *)model;


@end
