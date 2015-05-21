//
//  ThumbViewDragRefreshDelegate.m
//  MobileApp
//
//  Created by Dev on 9/2/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "ThumbViewDragRefreshDelegate.h"

// UI
#import "Three20UI/TTTableHeaderDragRefreshView.h"
#import "Three20UI/TTTableViewController.h"
#import "Three20UI/UIViewAdditions.h"

// UICommon

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet+DragRefreshHeader.h"

// Network
#import "Three20Network/TTModel.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"

#import "ThumbViewController.h"

// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
static const CGFloat kRefreshDeltaY = -65.0f;

// The height of the refresh header when it is in its "loading" state.
static const CGFloat kHeaderVisibleHeight = 60.0f;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ThumbViewDragRefreshDelegate

@synthesize headerView = _headerView;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject

- (UIEdgeInsets)edgeInsetsRetracted
{
	return [(ThumbViewController *) _controller edgeInsetsRetracted];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(ThumbViewController *)controller
{
	self = [super initWithController:controller];
	if ( self )
	{
		// Add our refresh header
		_headerView = [[TTTableHeaderDragRefreshView alloc]
				initWithFrame:CGRectMake( 0,
						-_controller.tableView.bounds.size.height,
						_controller.tableView.width,
						_controller.tableView.bounds.size.height )];
		_headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_headerView.backgroundColor = TTSTYLEVAR(tableRefreshHeaderBackgroundColor);
		[_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
		[_controller.tableView addSubview:_headerView];

		// Hook up to the model to listen for changes.
		_model = [controller.model retain];
		[_model.delegates addObject:self];

		// Grab the last refresh date if there is one.
		if ( [_model respondsToSelector:@selector(loadedTime)] )
		{
			NSDate *date = [_model performSelector:@selector(loadedTime)];

			if ( nil != date )
			{
				[_headerView setUpdateDate:date];
			}
		}

		// _controller.tableView.contentInset = UIEdgeInsetsZero;

		_controller.tableView.contentInset = [self edgeInsetsRetracted];

	}
	return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
	[_model.delegates removeObject:self];
	[_headerView removeFromSuperview];
	TT_RELEASE_SAFELY(_headerView);
	TT_RELEASE_SAFELY(_model);

	[super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[super scrollViewDidScroll:scrollView];

	if ( scrollView.dragging && !_model.isLoading )
	{
		if ( scrollView.contentOffset.y > kRefreshDeltaY
				&& scrollView.contentOffset.y < 0.0f )
		{
			[_headerView setStatus:TTTableHeaderDragRefreshPullToReload];

		}
		else if ( scrollView.contentOffset.y < kRefreshDeltaY )
		{
			[_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
		}
	}

	// This is to prevent odd behavior with plain table section headers. They are affected by the
	// content inset, so if the table is scrolled such that there might be a section header abutting
	// the top, we need to clear the content inset.
	if ( _model.isLoading )
	{
		if ( scrollView.contentOffset.y >= 0 )
		{
			_controller.tableView.contentInset = UIEdgeInsetsZero;

		}
		else if ( scrollView.contentOffset.y < 0 )
		{
			_controller.tableView.contentInset = UIEdgeInsetsMake( kHeaderVisibleHeight, 0, 0, 0 );
		}
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];

	// If dragging ends and we are far enough to be fully showing the header view trigger a
	// load as long as we arent loading already
	if ( scrollView.contentOffset.y <= kRefreshDeltaY && !_model.isLoading )
	{
		[[NSNotificationCenter defaultCenter]
				postNotificationName:@"DragRefreshTableReload" object:nil];
		[_model load:TTURLRequestCachePolicyNetwork more:NO];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidStartLoad:(id <TTModel>)model
{
	[_headerView setStatus:TTTableHeaderDragRefreshLoading];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
	if ( _controller.tableView.contentOffset.y < 0 )
	{
		_controller.tableView.contentInset = UIEdgeInsetsMake( kHeaderVisibleHeight, 0.0f, 0.0f, 0.0f );
	}
	[UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id <TTModel>)model
{
	[_headerView setStatus:TTTableHeaderDragRefreshPullToReload];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultTransitionDuration];
	_controller.tableView.contentInset = [self edgeInsetsRetracted];
	[UIView commitAnimations];

	if ( [model respondsToSelector:@selector(loadedTime)] )
	{
		NSDate *date = [model performSelector:@selector(loadedTime)];
		[_headerView setUpdateDate:date];

	}
	else
	{
		[_headerView setCurrentDate];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id <TTModel>)model didFailLoadWithError:(NSError *)error
{
	[_headerView setStatus:TTTableHeaderDragRefreshPullToReload];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultTransitionDuration];
	_controller.tableView.contentInset = [self edgeInsetsRetracted];
	[UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad:(id <TTModel>)model
{
	[_headerView setStatus:TTTableHeaderDragRefreshPullToReload];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultTransitionDuration];
	_controller.tableView.contentInset = [self edgeInsetsRetracted];
	[UIView commitAnimations];
}


@end
