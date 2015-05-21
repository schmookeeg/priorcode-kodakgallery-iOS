//
//  AlbumPickerController.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"
#import <Three20/Three20.h>


@interface ELCAlbumPickerController ()
- (void)reloadTableView;
@end

@implementation ELCAlbumPickerController

@synthesize parent, assetGroups = _assetGroups, library = _library;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	[[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];	

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
	[self.navigationItem setLeftBarButtonItem:cancelButton];
	[cancelButton release];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
    [tempArray release];

    // Load Albums into assetGroups in the background to not tie up the main thread
    dispatch_queue_t dispatch_queue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( dispatch_queue, ^
    {
        // Group enumerator Block
        ALAssetsLibraryGroupsEnumerationResultsBlock assetGroupEnumerator = ^(ALAssetsGroup *group, BOOL *stop) 
        {
            if ( group == nil )
            {
                // Reload the table after all of the groups have been added. 
				//
                // This has to be done in the main thread.
                dispatch_async( dispatch_get_main_queue(), ^
                               {
                                   [self reloadTableView];
                               });
				
                return;
            }
            
            if ( [(NSNumber *)[group valueForProperty:ALAssetsGroupPropertyType] isEqualToNumber:[NSNumber numberWithInt:ALAssetsGroupSavedPhotos]] )
            {
				// Place the camera roll group at the beginning of the list
				[self.assetGroups insertObject:group atIndex:0];
			} else {
				[self.assetGroups addObject:group];
			}

            // Keep this line!  w/o it the asset count is broken for some reason.  Makes no sense
            //NSLog( @"Found ALAssetsGroup: %@ (%d)",[group valueForProperty:ALAssetsGroupPropertyName], [group numberOfAssets] );
			[group numberOfAssets];
        };
        
        // Group Enumerator Failure Block
        ALAssetsLibraryAccessFailureBlock assetGroupEnumeratorFailure = ^(NSError *error)
        {
            NSLog(@"A problem occured %@", [error description]);	  
            
            dispatch_async( dispatch_get_main_queue(), ^
                           {
                               if ([error code] == -3310)
                               {
                                   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error Accessing Photos" message:@"Unable to access photo library. Please open the \"Photos\" application and try again."  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                   [alert show];
                                   [alert release];
                               }
                               else if ([error code] == -3311)
                               {
                                   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Photo Access Denied" message:@"Access to the photos has been denied. To reenable access you must reset all location warnings. (Settings->General->Reset->Reset Location Warnings)"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                   [alert show];
                                   [alert release];
                                   
                               }
                               else
                               {
                                   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@", [error description]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                   [alert show];
                                   [alert release];
                               }
                           });
        };	
                
        // Enumerate Albums
        self.library = [[[ALAssetsLibrary alloc] init] autorelease];        
        [_library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:assetGroupEnumerator 
                             failureBlock:assetGroupEnumeratorFailure];
    });
}

- (void)reloadTableView {
	[self.tableView reloadData];
	[self.navigationItem setTitle:@"Phone Albums"];
}

-(void)selectedAssets:(NSArray*)_assets {
	
	[(ELCImagePickerController*)parent selectedAssets:_assets];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[g valueForProperty:ALAssetsGroupPropertyName], gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName:@"ELCAssetTablePicker" bundle:[NSBundle mainBundle]];
	picker.parent = self;

    // Move me    
    picker.assetGroup = [self.assetGroups objectAtIndex:indexPath.row];
    [picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
	[self.navigationController pushViewController:picker animated:YES];
	[picker release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 57;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    
    self.assetGroups = nil;
}


- (void)dealloc 
{	
	[_assetGroups release];
    self.library = nil;
    [super dealloc];
}

@end

