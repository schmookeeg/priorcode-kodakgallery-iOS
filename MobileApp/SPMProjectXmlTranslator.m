//
//  Created by darron on 3/27/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SPMProjectXmlTranslator.h"
#import "UserModel.h"

@interface SPMProjectXmlTranslator (Private)

+ (DDXMLElement *)encodePage:(Page *)page intoPageNode:(DDXMLElement *) pageNode forSku:(SPMSKU *)sku;
+ (DDXMLElement *)encodeImageElement:(ImageElement *)imageElement withNode:(DDXMLElement *) photoHoleContent;
+ (CGFloat) spmOutputScaleForImageElement:(ImageElement *) imageElement scale:(CGFloat)scale;

@end

@implementation SPMProjectXmlTranslator

+ (DDXMLElement*)projectToXmlElement:(SPMProject *)project
{
	DDXMLElement *root = nil;
    if (project.projectXml == nil)
    {
        // Get project template
        [project populateProjectTemplate];
    }
    
    root = project.projectXml;
    
    NSLog(@"Projext XML from project object: %@", [root XMLString]);
    
    BOOL isNewProject = false;
    if ([root elementsForName:@"id"] == nil || [[((DDXMLElement *)[[root elementsForName:@"id"] objectAtIndex:0]) stringValue] isEqualToString:@"0"])
    {
        isNewProject = true;
    }
    
    if ([root elementsForName:@"ownerId"] == nil || [[root elementsForName:@"ownerId"] count] == 0)
    {
        [root addChild:[DDXMLNode elementWithName:@"ownerId" stringValue:[[UserModel userModel] sybaseId]]];
    }
    else
    {
        [((DDXMLElement *)[[root elementsForName:@"ownerId"] objectAtIndex:0]) setStringValue:[[UserModel userModel] sybaseId]];
    }
    
    SPMProductConfiguration *prodConfig = project.productConfiguration;
    SPMSKU *sku = [prodConfig.product.skus objectAtIndex:0];
    
    [((DDXMLElement *)[[root elementsForName:@"productId"] objectAtIndex:0]) setStringValue:sku.siteServicesProductId];
    [((DDXMLElement *)[[root elementsForName:@"name"] objectAtIndex:0]) setStringValue:sku.name];
    
     NSString *catInfo = [@"catId=" stringByAppendingFormat:@"%@:productId=%@:skuId=%@", prodConfig.product.catId, prodConfig.product.productId, sku.skuId];
    
    if ([root elementsForName:@"catalogInfo"] == nil || [[root elementsForName:@"catalogInfo"] count] == 0)
    {
        [root addChild:[DDXMLNode elementWithName:@"catalogInfo" stringValue:catInfo]];
    }
    else
    {
        [((DDXMLElement *)[[root elementsForName:@"catalogInfo"] objectAtIndex:0]) setStringValue:catInfo];
    }
     
    DDXMLElement *section = [[root elementsForName:@"section"] objectAtIndex:0];
    DDXMLElement *page = (DDXMLElement *)[[section elementsForName:@"page"] objectAtIndex:0];

    [page detach];
    
    page = [self encodePage:project.page intoPageNode:page forSku:sku];
	[section addChild:page];

	return root;
}

+ (DDXMLElement *)encodePage:(Page *)page intoPageNode:(DDXMLElement *) pageNode forSku:(SPMSKU *)sku
{
    DDXMLElement *pageArea = [[pageNode elementsForName:@"pageArea"] objectAtIndex:0];
    [((DDXMLElement *)[[pageArea elementsForName:@"xOff"] objectAtIndex:0]) setStringValue:[NSString stringWithFormat:@"%@",page.x]];
    [((DDXMLElement *)[[pageArea elementsForName:@"yOff"] objectAtIndex:0]) setStringValue:[NSString stringWithFormat:@"%@",page.y]];
    [((DDXMLElement *)[[pageArea elementsForName:@"height"] objectAtIndex:0]) setStringValue:[NSString stringWithFormat:@"%@",page.height]];
    [((DDXMLElement *)[[pageArea elementsForName:@"width"] objectAtIndex:0]) setStringValue:[NSString stringWithFormat:@"%@",page.width]];
    
    DDXMLElement *pageContent = (DDXMLElement *)[[pageNode elementsForName:@"pageContent"] objectAtIndex:0];
    DDXMLElement *canvasContent = (DDXMLElement *)[[pageContent childAtIndex:0] childAtIndex:0];
    [((DDXMLElement *)[[canvasContent elementsForName:@"canvasId"] objectAtIndex:0]) setStringValue:[((SPMLayout *)[sku.layouts objectAtIndex:0]) canvasId]];
    
    DDXMLElement *photoHoleContent = [[canvasContent elementsForName:@"photoHoleContent"] objectAtIndex:0];
    [photoHoleContent detach];
    

	// Encode all of the photo holes on the page
	for ( LayoutElement *layoutElement in page.layout.elements )
	{
		if ( [layoutElement isKindOfClass:[ImageElement class]] )
		{
			ImageElement *imageElement = (ImageElement *)layoutElement;
			if ( imageElement.type == ImageElementTypePhotoHole )
			{
                if (imageElement.photo == nil) continue;
				[canvasContent addChild:[self encodeImageElement:imageElement withNode:[photoHoleContent copy]]];
			}
		}
	}

	return pageNode;
}

+ (DDXMLElement *)encodeImageElement:(ImageElement *)imageElement withNode:(DDXMLElement *) photoHoleContent
{
    [((DDXMLElement *)[[photoHoleContent elementsForName:@"photoholeId"] objectAtIndex:0]) setStringValue:imageElement.photoHoleId];
    [((DDXMLElement *)[[photoHoleContent elementsForName:@"photoId"] objectAtIndex:0]) setStringValue:[imageElement.photo.photoId stringValue]];
    [((DDXMLElement *)[[photoHoleContent elementsForName:@"uri"] objectAtIndex:0]) setStringValue:imageElement.photo.bgUrl];
    [((DDXMLElement *)[[photoHoleContent elementsForName:@"width"] objectAtIndex:0]) setStringValue:[NSString stringWithFormat:@"%@",imageElement.photo.width]];
    [((DDXMLElement *)[[photoHoleContent elementsForName:@"height"] objectAtIndex:0]) setStringValue:[NSString stringWithFormat:@"%@",imageElement.photo.height]];

    CGFloat scale = [imageElement outputScale];
    CGFloat aspectRatio = [imageElement.photo.width floatValue] / [imageElement.photo.height floatValue];
    CGFloat frameAspectRatio = [imageElement.width floatValue] / [imageElement.height floatValue];
    
    CGFloat spmScale = [self spmOutputScaleForImageElement:imageElement scale:scale];
    
    CGPoint pt = [imageElement outputTranslation];
    
    CGFloat tx = pt.x*scale;
    CGFloat ty = pt.y*scale;
    
    CGFloat boundWidth = [imageElement.width floatValue]*spmScale;
    CGFloat boundHeight = [imageElement.height floatValue]*spmScale;
    
    if (frameAspectRatio < aspectRatio)
        boundWidth = boundHeight*aspectRatio;
    else boundHeight = boundWidth/aspectRatio;
    
    CGFloat deltaX = (boundWidth - [imageElement.width floatValue])/2;
    CGFloat deltaY = (boundHeight - [imageElement.height floatValue])/2;
    tx = tx + deltaX;
    ty = ty + deltaY;
    
    DDXMLElement *transforms = (DDXMLElement *)[[photoHoleContent elementsForName:@"transforms"] objectAtIndex:0];

    [((DDXMLElement *)[[transforms elementsForName:@"scale"] objectAtIndex:0]) setStringValue:[NSString stringWithFormat:@"%f",spmScale]];
    
    [((DDXMLElement *)[[transforms elementsForName:@"tx"] objectAtIndex:0]) setStringValue:[NSString stringWithFormat:@"%f",tx]];
    [((DDXMLElement *)[[transforms elementsForName:@"ty"] objectAtIndex:0]) setStringValue:[NSString stringWithFormat:@"%f",ty]];
    [((DDXMLElement *)[[transforms elementsForName:@"rotate"] objectAtIndex:0]) setStringValue:[NSString stringWithFormat:@"%@",imageElement.rotation]];
    [((DDXMLElement *)[[transforms elementsForName:@"tint"] objectAtIndex:0]) setStringValue:[imageElement tintStringValue]];

    /*
    CGRect viewBox = imageElement.resolutionIndependentCrop;
     
    phc.transforms.viewX = viewBox.x;
    phc.transforms.viewY = viewBox.y;
    phc.transforms.viewWidth = viewBox.width;
    phc.transforms.viewHeight = viewBox.height;
    */
    
    return photoHoleContent;
}

+ (CGFloat) spmOutputScaleForImageElement:(ImageElement *) imageElement scale:(CGFloat)scale
{
    CGFloat frameAspect = [imageElement.width floatValue] / [imageElement.height floatValue];
    CGFloat imgAspect = [imageElement.photo.width floatValue] / [imageElement.photo.height floatValue];
    
    CGFloat spmScale;
    
    if (frameAspect > imgAspect) 
    {
        // Rescale based on frame's width
        spmScale = (([imageElement.photo.width floatValue]/PRINT_DPI)*scale)/[imageElement.width floatValue];
    } else {
        // Rescale based on frame's height
        spmScale = (([imageElement.photo.height floatValue]/PRINT_DPI)*scale)/[imageElement.height floatValue];
    }
    return spmScale;			
}

@end