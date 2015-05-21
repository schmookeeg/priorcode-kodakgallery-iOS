//
//  Created by darron on 2/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SPMLayout.h"

@implementation SPMLayout

@synthesize layoutId = _layoutId;
@synthesize canvasId = _canvasId;
@synthesize background = _background;
@synthesize siteServicesCanvasId = _siteServicesCanvasId;
@synthesize noOfPhotoHoles = _noOfPhotoHoles;
@synthesize textBoxes = _textBoxes;
@synthesize photoHoles = _photoHoles;
@synthesize canvasAssets = _canvasAssets;

#pragma mark Init / Dealloc

- (id)init
{
    self = [super init];
    
	if ( self )
	{
		restKitElementArraysProcessed = NO;

        // All SPM layouts are template layouts
        self.layoutSyle = LayoutStyleTemplate;
	}
    
	return self;
}

- (void)dealloc
{
    [_background release];
    [_layoutId release];
    [_canvasId release];
	[_siteServicesCanvasId release];
	[_noOfPhotoHoles release];
	[_textBoxes release];
	[_photoHoles release];
	[_canvasAssets release];

	[super dealloc];
}

#pragma mark -

/**
 * Override element access so that the first access results in the combination
 * of the textBoxes and photoHoles array.
 */
- (NSMutableArray *)elements
{
	if ( !restKitElementArraysProcessed )
	{
		restKitElementArraysProcessed = YES;

		NSMutableArray *combined = [[NSMutableArray alloc] init];
		[combined addObjectsFromArray:_photoHoles];
		[combined addObjectsFromArray:_textBoxes];
		[combined addObjectsFromArray:_canvasAssets];

		// Sort by Z order
		NSSortDescriptor *zDescriptor = [[NSSortDescriptor alloc] initWithKey:@"z" ascending:YES];
		NSArray *sorted = [combined sortedArrayUsingDescriptors:[NSArray arrayWithObject:zDescriptor]];

		// Add the sorted and combined TextElements and ImageElements into the elements array.
		[super.elements addObjectsFromArray:sorted];

		[combined release];
		[zDescriptor release];
	}

	return super.elements;
}

- (void) setCanvasAssets:(NSArray *)canvasAssets
{
    if (canvasAssets != nil)
    {
        for (ImageElement *asset in canvasAssets)
        {
            asset.type = ImageElementTypeCanvasAsset;
        }
    }
    _canvasAssets = [canvasAssets copy];
}

- (ImageElement*)findPhotoHoleById:(NSString *)photoHoleId
{
    for ( LayoutElement *layoutElement in self.elements )
    {
        if ( [layoutElement isKindOfClass:[ImageElement class]] )
        {
            ImageElement *imageElement = (ImageElement*)layoutElement;
            if ( [imageElement.photoHoleId isEqualToString:photoHoleId] )
            {
                return imageElement;
            }
        }
    }
    
    return nil;
}

- (TextElement*)findTextBoxById:(NSString *)textBoxId
{
    for ( LayoutElement *layoutElement in self.elements )
    {
        if ( [layoutElement isKindOfClass:[TextElement class]] )
        {
            TextElement *textElement = (TextElement*)layoutElement;
            if ( [textElement.textBoxId isEqualToString:textBoxId] )
            {
                return textElement;
            }
        }
    }
    
    return nil;
}

- (NSString *)description 
{
	return [NSString stringWithFormat:@"<%@:%p Layout Id: %@\n \
            canvas Id: %@\n \
            siteServicesCanvasId: %@\n \
            noOfPhotoHoles: %@\n \
            x: %@\n \
            y: %@\n \
            width: %@\n \
            height: %@\n \
            textBoxes: %@\n \
            photoHoles: %@\n \
            canvasAssets: %@\n"
            , NSStringFromClass([self class]), self, self.layoutId, self.canvasId, self.siteServicesCanvasId, 
            self.noOfPhotoHoles, self.x, self.y, self.width, self.height, self.textBoxes, 
            self.photoHoles, self.canvasAssets];
}

@end