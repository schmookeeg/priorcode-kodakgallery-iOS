//
//  SelectThumbViewController.m
//  MobileApp
//
//  Created by Jon Campbell on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectThumbViewController.h"
#import "SelectThumbsDataSource.h"
#import "AlbumListModel.h"
#import "SelectSinglePhotoViewController.h"

@interface SelectThumbViewController (Private)

- (void)configureViewForMultipleSelectionState;
- (void)navigateToSelectSinglePhotoViewWithPhoto:(PhotoModel *)photo;

@end;

@implementation SelectThumbViewController

@synthesize selectedPhotos = _selectedPhotos;
@synthesize allowMultiplePhotoSelection = _allowMultiplePhotoSelection;
@synthesize selectPhotosDelegate = _selectPhotosDelegate;
@synthesize navigationMode = _navigationMode;
@synthesize selectedThumbViews = _selectedThumbViews;
@synthesize selectAllButton = _selectAllButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		// Custom initialization
        self.selectedPhotos = [[[NSMutableArray alloc] init] autorelease];
        self.selectedThumbViews = [[[NSMutableArray alloc] init] autorelease];
        self.navigationMode = NO;
		self.allowMultiplePhotoSelection = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)initToolBar; {
    // NO OP
}

- (void)thumbsTableViewCell:(TTThumbsTableViewCell *)cell didSelectPhoto:(id <TTPhoto>)photo withThumbView:(TTThumbView *)thumbView
{
	PhotoModel *photoModel = (PhotoModel *) photo;
	if (photoModel.selected) {
		[self.selectedPhotos removeObject:photo];
		[self.selectedThumbViews removeObject:thumbView];

		UIView *view = [thumbView.subviews objectAtIndex:0];
		[view removeFromSuperview];
	}
	else
	{
		[self.selectedPhotos addObject:photo];
		[self.selectedThumbViews addObject:thumbView];

		if ( self.allowMultiplePhotoSelection )
		{
			CGRect viewFrames = CGRectMake(0, 0, 75, 75);
			UIImageView *overlayView = [[[UIImageView alloc] initWithFrame:viewFrames] autorelease];
			[overlayView setImage:[UIImage imageNamed:@"Overlay.png"]];
			[overlayView setHidden:NO];

			[thumbView addSubview:overlayView];
		}
	}

    if ( self.allowMultiplePhotoSelection )
	{
		photoModel.selected = !photoModel.selected;

		self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"Add (%d)", self.selectedPhotos.count];
		self.navigationItem.rightBarButtonItem.enabled = (self.selectedPhotos.count > 0);
	}
	else
	{
		[self navigateToSelectSinglePhotoViewWithPhoto:photoModel];
	}
}

- (id <TTTableViewDataSource>)createDataSource {
    return [[[SelectThumbsDataSource alloc] initWithPhotoSource:_photoSource delegate:self] autorelease];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[self configureViewForMultipleSelectionState];
}
	
- (void)setAllowMultiplePhotoSelection:(BOOL)allowMultiplePhotoSelection
{
	if ( _allowMultiplePhotoSelection != allowMultiplePhotoSelection )
	{
		_allowMultiplePhotoSelection = allowMultiplePhotoSelection;

		[self configureViewForMultipleSelectionState];
	}
}

- (void)configureViewForMultipleSelectionState
{
	if ( self.allowMultiplePhotoSelection )
	{
		self.viewMode = SelectPrints;
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Add (0)" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)] autorelease];
		self.navigationItem.rightBarButtonItem.enabled = NO;

		UIBarButtonItem *fixedItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL] autorelease];
		fixedItem.width = (self.view.frame.size.width / 2) - 60;

		self.selectAllButton = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Add All (%d)", self.photoSet.photos.count]
																		 style:UIBarButtonItemStyleBordered target:self action:@selector(selectAll:)] autorelease];

		[self.selectAllButton setEnabled:NO];


		self.toolbarItems = [NSArray arrayWithObjects:fixedItem, self.selectAllButton, nil];
		self.navigationController.toolbarHidden = NO;

		UIToolbar *toolbar = self.navigationController.toolbar;
		toolbar.barStyle = UIBarStyleBlack;
		toolbar.alpha = 0.9;
		toolbar.backgroundColor = [UIColor blackColor];
		toolbar.translucent = YES;

        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Prints:SelectPhotos"];
	}
	else
	{
		self.navigationItem.rightBarButtonItem = nil;

		self.selectAllButton = nil;
		self.toolbarItems = nil;
		self.navigationController.toolbarHidden = YES;
        
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Shop:Select Photo"];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Force the toolbar to hide since we're done with it.
    self.toolbarItems = nil;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    for (TTThumbView *thumbView in self.selectedThumbViews) {
        NSArray *subviews = [thumbView subviews];

        if ([subviews count] > 0) {
            UIView *view = [subviews objectAtIndex:[subviews count] - 1];
            [view removeFromSuperview];
        }
    }

	for ( PhotoModel *photo in self.selectedPhotos )
	{
		photo.selected = NO;
	}

    self.selectedThumbViews = [[[NSMutableArray alloc] init] autorelease];
    self.selectedPhotos = [[[NSMutableArray alloc] init] autorelease];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)modelDidFinishLoad:(id <TTModel>)model
{
	[super modelDidFinishLoad:model];

	self.navigationItem.title = self.allowMultiplePhotoSelection ? @"Select photos" : @"Select photo";

    if (self.navigationMode) {
        self.navigationItem.hidesBackButton = NO;
    } else {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)] autorelease];
    }

	self.selectAllButton.title = [NSString stringWithFormat:@"Add All (%d)", ((AlbumPhotoSource *) model).photos.count];
	[self.selectAllButton setEnabled:YES];
}

- (void)doneAction
{
	// Inform the delegate of the selected photos
	if ( [_selectPhotosDelegate respondsToSelector:(@selector(selectPhotosDidSelectPhotos:inAlbum:)) ] )
	{
		AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:_albumId];
		[_selectPhotosDelegate selectPhotosDidSelectPhotos:self.selectedPhotos inAlbum:album];
	}

	// If we're a modal view controller we dismiss after selection, otherwise
	// we do nothing.
	if ( !self.navigationMode )
	{
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)cancel {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)selectAll:(id)sender {
    self.selectedPhotos = [[[NSMutableArray alloc] init] autorelease];


    int count = [self.photoSource numberOfPhotos];

    for (int i = 0; i < count; i++) {
        PhotoModel *photo = (PhotoModel *) [self.photoSource photoAtIndex:i];
        [self.selectedPhotos addObject:photo];
    }

    self.navigationItem.rightBarButtonItem.enabled = (self.selectedPhotos.count > 0);

    [self doneAction];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_selectedPhotos release];
    [_parentControllerDelegate release];
    [_selectedThumbViews release];
    [_selectAllButton release];
    [super dealloc];
}

/**
 * Override
 */
- (TTPhotoViewController *)createPhotoViewController
{
	SelectSinglePhotoViewController *spvController = [[SelectSinglePhotoViewController alloc] init];
	spvController.albumId = self.albumId;
	return [spvController autorelease];
}

- (void)navigateToSelectSinglePhotoViewWithPhoto:(PhotoModel *)photo
{
	SelectSinglePhotoViewController *controller = (SelectSinglePhotoViewController *)[self createPhotoViewController];
	controller.centerPhoto = photo;
	controller.selectPhotosDelegate = self.selectPhotosDelegate;

	[self.navigationController pushViewController:controller animated:YES];
}

@end
