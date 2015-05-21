//
//  AlbumPickerController.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ELCAlbumPickerController : UITableViewController {
	
	NSMutableArray *_assetGroups;
	NSOperationQueue *queue;
	id parent;
    ALAssetsLibrary *_library;
}

@property (nonatomic, assign) id parent;
@property (nonatomic, retain) NSMutableArray *assetGroups;
@property (nonatomic, retain) ALAssetsLibrary *library;

-(void)selectedAssets:(NSArray*)_assets;

@end

