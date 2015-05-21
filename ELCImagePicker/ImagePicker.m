//
//  ImagePicker.m
//  ELCImagePickerDemo
//
//  Created by Peter Traeg on 5/10/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "ImagePicker.h"
#import "ELCImagePickerDemoAppDelegate.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"


@implementation ImagePicker

- (void) dealloc
{
//	RELEASE_TO_NIL(recipients);
	[super dealloc];
}

-(void)_destroy
{
//	RELEASE_TO_NIL(recipients);
//	[super _destroy];
}


// Get the recipients array

-(NSArray *)assetURLs
{
	return assetURLs;
}

-(IBAction)showPicker {
	
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];    
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    
    ELCImagePickerDemoAppDelegate *app = (ELCImagePickerDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
	[app.viewController presentModalViewController:elcPicker animated:YES];
    [elcPicker release];
    [albumController release];
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    
    ELCImagePickerDemoAppDelegate *app = (ELCImagePickerDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
	[app.viewController dismissModalViewControllerAnimated:YES];
    
    [assetURLs release];
    assetURLs = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in info) {
        NSURL *assetUrl = [dict objectForKey:@"UIImagePickerControllerReferenceURL"];
        [assetURLs addObject:[assetUrl absoluteString]];
	}
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    
    ELCImagePickerDemoAppDelegate *app = (ELCImagePickerDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
	[app.viewController dismissModalViewControllerAnimated:YES];
}

- (UIImage *)getThumbImageForAssetURL:(NSURL *)imageUrl {
    __block UIImage *retImage;
    //
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        CGImageRef iref = [myasset thumbnail];
        if (iref) {
            retImage = [UIImage imageWithCGImage:iref];
            [retImage retain];
        }
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"Ooops, cant get image - %@",[myerror localizedDescription]);
    };
    
    ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    [assetslibrary assetForURL:imageUrl 
                   resultBlock:resultblock
                  failureBlock:failureblock];
    return retImage;
}

- (UIImage *)getScreenImageForAssetURL:(NSURL *)imageUrl {
    __block UIImage *retImage;
    //
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullScreenImage];
        if (iref) {
            retImage = [UIImage imageWithCGImage:iref];
            [retImage retain];
        }
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"Ooops, cant get image - %@",[myerror localizedDescription]);
    };
    
    ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    [assetslibrary assetForURL:imageUrl 
                   resultBlock:resultblock
                  failureBlock:failureblock];
    return retImage;
}

- (UIImage *)getFullImageForAssetURL:(NSURL *)imageUrl {
    __block UIImage *retImage;
    //
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            retImage = [UIImage imageWithCGImage:iref];
            [retImage retain];
        }
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"Ooops, cant get image - %@",[myerror localizedDescription]);
    };
    
    ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    [assetslibrary assetForURL:imageUrl 
                   resultBlock:resultblock
                  failureBlock:failureblock];
    return retImage;
}


@end
