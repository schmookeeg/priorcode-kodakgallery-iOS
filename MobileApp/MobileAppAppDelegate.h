//
//  MobileAppAppDelegate.h
//  MobileApp
//
//  Created by Jon Campbell on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <RestKit/Restkit.h>
#import "AlbumModelDelegate.h"
#import "UploadModelDelegate.h"
#import "IncomingURLHandler.h"
#import "EventNavigationController.h"

//@class ELCImagePickerDemoViewController;


@interface MobileAppAppDelegate : NSObject <UIApplicationDelegate, AlbumModelDelegate, UIAlertViewDelegate>
{
	BOOL networkWasPreviouslyReachable;
	IncomingURLHandler *_incomingURLHandler;
	UIAlertView *noConnectionAlert;
	EventNavigationController *_eventNavController;
}

@property ( nonatomic, retain ) IBOutlet UIWindow *window;
@property ( nonatomic, retain ) IncomingURLHandler *incomingURLHandler;

@property ( nonatomic, retain, readonly ) NSManagedObjectContext *managedObjectContext;
@property ( nonatomic, retain, readonly ) NSManagedObjectModel *managedObjectModel;
@property ( nonatomic, retain, readonly ) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)initReachability;
- (void)reachabilityChanged:(NSNotification *)note;
- (void)registerObjectMappings;
- (void)initNavigationController;
- (void)initOmniture;
- (void)saveContext;
- (void)updateReachability:(RKReachabilityObserver *)observer;
- (void)initAddThis;

- (NSURL *)applicationDocumentsDirectory;
+ (NSString *)applicationVersion;

@end
