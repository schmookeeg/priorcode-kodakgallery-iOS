//
//  Created by jcampbell on 2/9/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TabBarController.h"
#import "ThumbViewController.h"
#import "SinglePhotoViewController.h"
#import "Three20UI/Three20UI+Additions.h" 

@implementation TabBarController

- (void)viewDidLoad
{
    [self setTabURLs:[NSArray arrayWithObjects:
            @"tt://albumList", // photos
            @"tt://notifications", // notifications
            @"tt://shop", // shop
            nil]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    BOOL validClass = [[TTNavigator navigator].visibleViewController isKindOfClass:[SinglePhotoViewController class]]
                    || [[TTNavigator navigator].visibleViewController isKindOfClass:[ThumbViewController class]];

    if ( validClass )
    {
        return YES;
    }
    else
    {
        return UIInterfaceOrientationIsPortrait( toInterfaceOrientation );
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    // Selecting the shop tab should always pop out to the root view (Shop page)
    if ( [item.title isEqualToString:@"Shop"] )
    {
        // Get the navigator associated with the shop tab
        TTNavigationController *controller = (TTNavigationController*)[self.viewControllers objectAtIndex:2];
        // Restore the shop tab back to it's root view
        [controller popToRootViewControllerAnimated:NO];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end