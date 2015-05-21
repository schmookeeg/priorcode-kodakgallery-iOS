//
//  SPMRestKitTranslator.m
//  MobileApp
//
//  Created by Darron Schall on 2/28/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "SPMRestKitTranslator.h"
#import <RestKit/RestKit.h>
#import "SPMProductConfiguration.h"
#import "SPMProductList.h"
#import "AvailableFont.h"

@implementation SPMRestKitTranslator

+ (void)initializeRestKitMappings
{
    // Regsister an obect mapping to handle the translation
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    //////  BulkPrice
    RKObjectMapping *bulkPriceMapping = [RKObjectMapping mappingForClass:[BulkPrice class]];
    bulkPriceMapping.setDefaultValueForMissingAttributes = YES;
    bulkPriceMapping.setNilForMissingRelationships = YES;
    [bulkPriceMapping mapKeyPathsToAttributes:
     @"low_bound", @"lowBound",
     @"high_bound", @"highBound",
     @"price", @"price",
     @"salePrice", @"salePrice",
     nil];

    //////  AvailableFont
    RKObjectMapping *availableFontMapping = [RKObjectMapping mappingForClass:[AvailableFont class]];
    availableFontMapping.setDefaultValueForMissingAttributes = YES;
    availableFontMapping.setNilForMissingRelationships = YES;
    [availableFontMapping mapKeyPathsToAttributes:
     @"id", @"fontId",
     @"family", @"family",
     @"styles", @"stylesCSV",
     @"sizes", @"sizesCSV",
     nil];

	//////  FontInstance
	RKObjectMapping *fontInstanceMapping = [RKObjectMapping mappingForClass:[FontInstance class]];
	fontInstanceMapping.setDefaultValueForMissingAttributes = YES;
	fontInstanceMapping.setNilForMissingRelationships = YES;
	[fontInstanceMapping mapKeyPathsToAttributes:
	 @"family", @"family",
	 @"style", @"style",
	 @"size", @"size",
	 @"color", @"color",
	 nil];

    //////  TextBox
    RKObjectMapping *textBoxMapping = [RKObjectMapping mappingForClass:[TextElement class]];
    textBoxMapping.setDefaultValueForMissingAttributes = YES;
    textBoxMapping.setNilForMissingRelationships = YES;
    [textBoxMapping mapKeyPathsToAttributes:
	@"id", @"textBoxId",
	@"height", @"height",
	@"width", @"width",
	@"xoffset", @"x",
	@"yoffset", @"y",
	@"rotation", @"rotation",
	@"z", @"z",
     @"horizontalJustification", @"horizontalJustification",
     @"verticalJustification", @"verticalJustification",
     @"text", @"text",
     @"availableFontColors", @"availableColorsCSV",
	 nil];
	[textBoxMapping mapKeyPath:@"AvailableFonts" toRelationship:@"availableFonts" withMapping:availableFontMapping];
	[textBoxMapping mapKeyPath:@"defaultFont" toRelationship:@"defaultFont" withMapping:fontInstanceMapping];
    
    //////  PhotoHole
    RKObjectMapping *photoHoleMapping = [RKObjectMapping mappingForClass:[ImageElement class]];
    photoHoleMapping.setDefaultValueForMissingAttributes = YES;
    photoHoleMapping.setNilForMissingRelationships = YES;
    [photoHoleMapping mapKeyPathsToAttributes:
     @"id", @"photoHoleId",
     //@"units", @"units",
     @"height", @"height",
     @"width", @"width",
     @"xoffset", @"x",
     @"yoffset", @"y",
     @"rotation", @"rotation",
     @"z", @"z",
     nil];

    //////  CanvasAsset
    RKObjectMapping *canvasAssetMapping = [RKObjectMapping mappingForClass:[ImageElement class]];
    canvasAssetMapping.setDefaultValueForMissingAttributes = YES;
    canvasAssetMapping.setNilForMissingRelationships = YES;
    [canvasAssetMapping mapKeyPathsToAttributes:
     @"id", @"photoHoleId",
     //@"units", @"units",
     @"height", @"height",
     @"width", @"width",
     @"xoffset", @"x",
     @"yoffset", @"y",
     @"rotation", @"rotation",
     @"z", @"z",
     @"assetUri", @"assetUri",
     nil];
    
    //////  Layout
    RKObjectMapping *layoutMapping = [RKObjectMapping mappingForClass:[SPMLayout class]];
    layoutMapping.setDefaultValueForMissingAttributes = YES;
    layoutMapping.setNilForMissingRelationships = YES;
    [layoutMapping mapKeyPathsToAttributes:
     //@"layoutImage", @"background",
     @"id", @"layoutId",
     @"siteServicesCanvasId", @"siteServicesCanvasId",
     //@"units", @"units",
     @"holes", @"noOfPhotoHoles",
     @"CanvasData.id", @"canvasId",
     @"CanvasData.height", @"height",
     @"CanvasData.width", @"width",
     @"CanvasData.xoffset", @"x",
     @"CanvasData.yoffset", @"y",
     //@"CanvasData.rotation", @"rotation",
     //@"CanvasData.z", @"z",
     nil];
    [layoutMapping mapKeyPath:@"CanvasData.TextBoxes" toRelationship:@"textBoxes" withMapping:textBoxMapping];
    [layoutMapping mapKeyPath:@"CanvasData.PhotoHoles" toRelationship:@"photoHoles" withMapping:photoHoleMapping];
    [layoutMapping mapKeyPath:@"CanvasData.CanvasAssets" toRelationship:@"canvasAssets" withMapping:canvasAssetMapping];
    
    //////  SKU
    RKObjectMapping *skuMapping = [RKObjectMapping mappingForClass:[SPMSKU class]];
    skuMapping.setDefaultValueForMissingAttributes = NO;
    skuMapping.setNilForMissingRelationships = YES;
    [skuMapping mapKeyPathsToAttributes:
     @"skuId", @"skuId",
     @"siteServicesProductId", @"siteServicesProductId",
     @"name", @"name",
     @"price_bulk", @"priceBulk",
     @"price", @"price",
     @"salePrice", @"salePrice",
     nil];
    //[objectManager.mappingProvider registerMapping:skuMapping withRootKeyPath:@"SKU"];
    [skuMapping mapKeyPath:@"price_bands.price_band" toRelationship:@"bulkPrices" withMapping:bulkPriceMapping];
    [skuMapping mapKeyPath:@"Layouts.Layout" toRelationship:@"layouts" withMapping:layoutMapping];
    
    //////  SPMProduct
    RKObjectMapping *spmProductMapping = [RKObjectMapping mappingForClass:[SPMProduct class]];
    spmProductMapping.setDefaultValueForMissingAttributes = NO;
    spmProductMapping.setNilForMissingRelationships = YES;
    [spmProductMapping mapKeyPathsToAttributes:
     @"productId", @"productId",
     @"type", @"type",
     @"catId", @"catId",
     nil];
    //[objectManager.mappingProvider registerMapping:spmProductMapping withRootKeyPath:@"Product"];

    
    [spmProductMapping mapKeyPath:@"SKU" toRelationship:@"skus" withMapping:skuMapping];

    
    RKObjectMapping *spmProductListMapping = [RKObjectMapping mappingForClass:[SPMProductList class]];
    spmProductListMapping.setDefaultValueForMissingAttributes = YES;
    spmProductListMapping.setNilForMissingRelationships = NO;
    [spmProductListMapping mapKeyPath:@"Product" toRelationship:@"products" withMapping:spmProductMapping];
    [objectManager.mappingProvider registerMapping:spmProductListMapping withRootKeyPath:@"Products"];    

}

@end
