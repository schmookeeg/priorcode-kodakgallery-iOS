//
//  UIViewController+TDSemiModalExtension.h
//  TDSemiModal
//
//  Created by Nathan  Reed on 18/10/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import "TDSemiModalViewController.h"

@interface UIViewController (TDSemiModalExtension)
-(void)presentSemiModalViewController:(TDSemiModalViewController*)vc withDuration:(CGFloat) duration;
-(void)dismissSemiModalViewController:(TDSemiModalViewController*)vc withDuration:(CGFloat) duration;


- (void)presentSemiModalViewController:(TDSemiModalViewController*)vc;
- (void)dismissSemiModalViewController:(TDSemiModalViewController*)vc; 

@end
