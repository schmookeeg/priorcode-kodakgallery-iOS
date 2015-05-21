//
//  SPMProductListDataSource.m
//  MobileApp
//
//  Created by Darron Schall on 2/27/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "SPMProductListDataSource.h"
#import "SPMProductConfiguration.h"
#import "SPMRestKitTranslator.h"
#import "SPMProject.h"
#import "AlbumListModel.h"
#import "SPMProjectTableItem.h"
#import "SPMProjectTableItemCell.h"

@interface SPMProductListDataSource (Private)

- (void)populateDataSourceFromModel;

@end

@implementation SPMProductListDataSource

@synthesize productList = _productList;
@synthesize albumId = _albumId;
@synthesize photoId = _photoId;

#pragma mark Init / Dealloc

+ (void) initialize
{
    if ([self class] == [SPMProductListDataSource class])
    {
        // One-time initialize for only this class

        [SPMRestKitTranslator initializeRestKitMappings];
    }

    // Initialization for this class and any subclasses
}

- (id)initWithAlbumId:(NSNumber *)albumId photoId:(NSNumber *)photoId
{
	self = [self init];
	if ( self )
	{
		self.albumId = albumId;
		self.photoId = photoId;
	}
	return self;
}

- (id)init
{
    self = [super init];
    if ( self )
    {
        _productList = [[SPMProductList alloc] init];
        _productList.delegate = self;

        _isLoaded = NO;

    }
    return self;
}

- (void)dealloc
{
    [_productList release];
	[_albumId release];
	[_photoId release];

    [_delegates release];

	[super dealloc];
}

#pragma mark Loading

- (NSMutableArray *)delegates
{
	if ( nil == _delegates )
	{
		_delegates = TTCreateNonRetainingArray();
	}
	return _delegates;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
    // If we already have the product configurations loaded, we don't need to reload data
    // from the server.
    if ( [self.productList.products count] > 0 )
    {
// Commented out - the changePhotoToPhotoId:inAlbumId: handles the change photo case
//        // However, in the event the photo has changed, we need to update all of the items to be created
//        // with the new photo.
//        // FIXME: Write conditional for photo changing
//        if ( YES )
//        {
//            // These two lines are here to handle the mock case just so we can get the initial
//            // load complete and displaying without having to wait for the call to timeout first.
//            [self.delegates makeObjectsPerformSelector:@selector(modelDidStartLoad:) withObject:self];
//            _isLoaded = YES;
//            // Once we've integrated with the server, delete the above two lines.
//
//
//            [self populateDataSourceFromModel];
//
//            [self.delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];
//        }
    }
    else
    {
        [super load:cachePolicy more:more];

        _isLoaded = NO;

        [self.productList fetch];

        [self.delegates makeObjectsPerformSelector:@selector(modelDidStartLoad:) withObject:self];
    }
}

- (BOOL)isLoading
{
	return !_isLoaded;
}

- (BOOL)isLoaded
{
	return _isLoaded;
}

#pragma mark AbstractModelDelegate

- (void)didModelLoad:(AbstractModel *)model
{
    _isLoaded = YES;

    [self populateDataSourceFromModel];

    [self.delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];
}

- (void)didModelLoadFail:(AbstractModel *)model withError:(NSError *)error
{
    _isLoaded = YES;

    [AbstractModel uncaughtFailure];

    // For now, populate even in the failure case because we'r ejust using mock data and
    // we don't have an endpoint to hit.
    [self populateDataSourceFromModel];

    [self.delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];
}

- (PhotoModel*)currentPhoto
{
    AbstractAlbumModel *album = [[AlbumListModel albumList] albumFromAlbumId:self.albumId];
	PhotoModel *photoModel = [album photoFromId:self.photoId];
    
	if ( !photoModel )
	{
		// If we can't match the album and photo then we can't populate the
		// photo holes with an initial value.
        
		// FIXME: Do we show an error message saying try again later and pop the view
		// or do we just leave this as-is and show photo holes?
		NSLog( @"No photo to substitute in photo holes of products in product list." );
	}
    
    return photoModel;
}

- (void)populateDataSourceFromModel
{
    // The array that is going to store the table items.
    NSMutableArray *tempItems = [NSMutableArray array];
    
    PhotoModel *photo = [self currentPhoto];

    // Loop through all of the available product configurations and turn each
    // one into an SPMProject, filling the template layout with the selected
    // photo and configuring an SPMTableItem to hold the project information.
	//for ( SPMProductConfiguration *productConfiguration in self.productList.productConfigurations )
	for ( SPMProduct *product in self.productList.products )
	{
        for ( SPMSKU *sku in product.skus )
        {
            if ( sku.layouts == nil || ( [sku.layouts count] <= 0 ) )
			{
				continue;
			}

			SPMProductConfiguration *productConfiguration = [[SPMProductConfiguration alloc] init];
			productConfiguration.product = product;
			productConfiguration.sku = sku;
            
            // We'll just use the first layout and ignore others
			productConfiguration.layout = [sku.layouts objectAtIndex:0];

			SPMProject *project = [[SPMProject alloc] init];
			project.productConfiguration = productConfiguration;
			[project createPageUsingPhoto:photo];

			[tempItems addObject:project];

			// Cleanup
			[productConfiguration release];
			[project release];
        }
	}

    NSMutableArray *items = [NSMutableArray array];
    for ( NSUInteger i = 0; i < [tempItems count]; i += 2 )
    {
        SPMProject *project1 = nil;
        SPMProject *project2 = nil;
        
        project1 = [tempItems objectAtIndex:i];
        
        // Check if there are 2 magnets to display on the row or not.
        if ((i+1) < [tempItems count])
        {
            project2 = [tempItems objectAtIndex:i+1];
        }
        
        SPMProjectTableItem *item = [SPMProjectTableItem itemWithProject1:project1 project2:project2];
        
        // TRICKY: Can't set the URL string because we have to supply a dictionary along with the
        // url, so in order to do that we use the delegate/selector approach instead, and navigate
        // to the url manually.
        item.delegate = self;
        item.selector = @selector(navigateToProject:);
        
        [items addObject:item];
    }

	self.items = items;
}

#pragma mark Helpers

- (void)changeToPhoto:(PhotoModel *)photo onPage:(Page *)page
{
    for ( LayoutElement *layoutElement in page.layout.elements )
    {
        if ( [layoutElement isKindOfClass:[ImageElement class]] )
        {
            ImageElement *imageElement = (ImageElement *) layoutElement;
            if ( imageElement.type == ImageElementTypePhotoHole )
            {
                // Replace the existing photo with the new photo
                imageElement.photo = photo;
                // Make the new photo fit into the photo hole
                [imageElement centerCropToFillUsingRotation:0];
            }
        }
    }

}

- (void)changePhotoToPhotoId:(NSNumber *)photoId inAlbumId:(NSNumber *)albumId
{
	self.albumId = albumId;
	self.photoId = photoId;

	// If we're already loaded, update the data source to use the new photo/album combination
	// and then refresh the table.
	if ( [self isLoaded] )
	{
        PhotoModel *photo = [self currentPhoto];
        
        // Loop through all of the existing items and reset the image
        // Replace the image in the product with the image that we just selected
        for ( SPMProjectTableItem *item in self.items )
        {
            [self changeToPhoto:photo onPage:item.project1.page];
            [self changeToPhoto:photo onPage:item.project2.page];
        }

		[self.delegates makeObjectsPerformSelector:@selector(modelDidFinishLoad:) withObject:self];
	}
}

#pragma mark - Table view integration

/**
 * Invoked when a project is selected in the table row.  Navigate to the details screen for the selected project.
 */
- (void)navigateToProject:(id)project
{
	// Project is either an SPMProject* when a CanvasRenderer is touched, or a SPMProjectTableITem* if
	// the row content (outside the canvas area) is touched.
	//
	// Bail out if we're not trying to navigate to a project
	if ( ![project isKindOfClass:[SPMProject class]] )
	{
		return;
	}

    // Create a query to pass complex data into the view.
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:project, @"project", self, @"dataSource", nil];

	// Navigate to the product details, passing the project information along
    TTURLAction *actionUrl = [[[TTURLAction actionWithURLPath:@"tt://productDetail"] applyAnimated:YES] applyQuery:dictionary];
    [[TTNavigator navigator] openURLAction:actionUrl];
}

/**
 * Override so we can link the SPMProjectTableItem to our custom SPMProjectTableItemCell.
 */
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object
{
	if ( [object isKindOfClass:[SPMProjectTableItem class]] )
	{
		return [SPMProjectTableItemCell class];
	}
	else
	{
		return [super tableView:tableView cellClassForObject:object];
	}
}

@end
