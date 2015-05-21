//
//  TDSemiModalViewController.m
//  TDSemiModal
//
//  Created by Nathan  Reed on 18/10/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import "TDSemiModalViewController.h"

@implementation TDSemiModalViewController

@synthesize coverView;

-(void)viewDidLoad {
    [super viewDidLoad];
	
	self.coverView.backgroundColor = [UIColor blackColor];

	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark -
#pragma mark Memory Management

- (void)viewDidUnload {
	self.coverView = nil;
	[super viewDidUnload];
}

- (void)dealloc
{
    self.coverView = nil;
    [super dealloc];
}

@end