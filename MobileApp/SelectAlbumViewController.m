    //
//  Created by jcampbell on 2/8/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SelectAlbumViewController.h"
#import "AlbumListDataSource.h"
#import "SelectThumbViewController.h"

@implementation SelectAlbumViewController

@synthesize allowMultiplePhotoSelection = _allowMultiplePhotoSelection;
@synthesize selectPhotosDelegate = _selectPhotosDelegate;

#pragma mark init / dealloc

- (void)commonInit
{
	self.allowMultiplePhotoSelection = YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if ( self )
	{
		[self commonInit];
	}
	return self;
}

- (id)init
{
	self = [super init];
	if ( self )
	{
		[self commonInit];
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    AlbumListDataSource *dataSource = (AlbumListDataSource *)self.dataSource;
    AbstractAlbumModel *album = [dataSource.visibleAlbums objectAtIndex:indexPath.row];

    NSString *navUrl = [NSString stringWithFormat:@"tt://selectPhotosInAlbumNav/%@", album.albumId];

    SelectThumbViewController *viewController = (SelectThumbViewController *) [[TTNavigator navigator] openURLAction:
            [[TTURLAction actionWithURLPath: navUrl] applyAnimated:YES]];
    viewController.navigationMode = YES;
	viewController.allowMultiplePhotoSelection = self.allowMultiplePhotoSelection;
	viewController.selectPhotosDelegate = self.selectPhotosDelegate;
}

- (BOOL)isModal
{
	// We're modal if we're the first one on the stack, otherwise we've been pushed.
	return [[self.navigationController viewControllers] objectAtIndex:0] == self;
}

- (void)viewWillAppear:(BOOL)animated
{
    ((AlbumListDataSource *)self.dataSource).hideEmpty = YES;
    self.lastRefreshDate = nil;

    [super viewWillAppear:animated];

    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = @"Select Album";

	if ( self.allowMultiplePhotoSelection )
	{
		[[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Prints:SelectAlbum"];
	}
    else
    {
        [[AnalyticsModel sharedAnalyticsModel] trackPageview:@"m:Shop:Select Album"];
    }


	if ( [self isModal] )
	{
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
	}
    
    // Re-claim the delegate to be the current data source for the album list when this album list view loads.
    ((AlbumListDataSource*)self.dataSource).albumList.delegate = ((AlbumListDataSource*)self.dataSource);
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Clear the delegate for the album list.  Prevents a crash when "cancel" the select photos
    // before the album list has actually loading (before the delegate fires).
    ((AlbumListDataSource*)self.dataSource).albumList.delegate = nil;
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldOpenURL:(NSString*)URL {
    return NO;
}

- (BOOL)showLogo {
    return NO;
}

- (BOOL)hidesBottomBarWhenPushed{
	return YES;
}

- (void)cancelAction:(id)sender
{
	if ( [self.selectPhotosDelegate respondsToSelector:@selector(selectPhotosDidCancel)] )
	{
		[self.selectPhotosDelegate selectPhotosDidCancel];
	}
}


@end
