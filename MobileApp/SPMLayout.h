//
//  Created by darron on 2/24/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Layout.h"
#import "ImageElement.h"
#import "TextElement.h"

@interface SPMLayout : Layout
{
	BOOL restKitElementArraysProcessed;
}

@property ( nonatomic, retain ) NSString *layoutId;
@property ( nonatomic, retain ) NSString *canvasId;
@property ( nonatomic, retain ) ImageElement *background;
@property ( nonatomic, retain ) NSString *siteServicesCanvasId;
@property ( nonatomic, retain ) NSNumber *noOfPhotoHoles;

/**
 * This property exists solely for server integration: RestKit populates
 * textBoxes with TextElement instances.  This information is then fed
 * into the regular elements property.
 *
 * You should always use elements when accessing the layout contents.
 *
 * Modifications to textBoxes after the server has populate the value
 * will not be correctly reflected in the elements array.
 */
@property ( nonatomic, retain ) NSArray *textBoxes; // Array of TextElement

/**
 * These properties exists solely for server integration: RestKit populates
 * photoHoles with ImageElement instances.  This information is then fed
 * into the regular elements property.
 *
 * You should always use elements when accessing the layout contents.
 *
 * Modifications to photoHoles after the server has populate the value
 * will not be correctly reflected in the elements array.
 */
@property ( nonatomic, retain ) NSArray *photoHoles; // Array of ImageElement
@property ( nonatomic, retain ) NSArray *canvasAssets; // Array of ImageElement

- (ImageElement*)findPhotoHoleById:(NSString *)photoHoleId;

- (TextElement*)findTextBoxById:(NSString *)textBoxId;

@end