//
//  Created by jcampbell on 2/7/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrintsAddedModalAlertView.h"
#import <Three20/Three20.h>


@implementation PrintsAddedModalAlertView

@synthesize imageView = _imageView;
@synthesize alertView = _alertView, alertTitle = _alertTitle, alertMessage = _alertMessage;


- (id)initWithPhotoCount:(int)photoCount {
    self = [super init];
    if (self) {
        // Custom initialization
        self.alertTitle = @"";

        if (photoCount == 1) {
            self.alertMessage = @"\n\n1 photo \n added to Print Order";
        } else {
            self.alertMessage = [NSString stringWithFormat:@"\n\n%d photos \n added to Print Order", photoCount];
        }

        self.alertView = [[[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View Order", nil] autorelease];

        self.imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AddPrintIcon@2x.png"]] autorelease];
        self.imageView.frame = CGRectMake(112, 15, self.imageView.image.size.width, self.imageView.image.size.height);
        
        
        [self.alertView addSubview:self.imageView];

    }
    return self;
}

- (void)show {
    _alertView.title = _alertTitle;
    _alertView.message = _alertMessage;
    [_alertView show];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 1 )
    {
        // Navigate to the shop tab, and then on to the cart.
        [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://shop"] applyAnimated:NO]];
        [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://buyPrints/web/cart"] applyAnimated:NO]];
    }
    else if ( buttonIndex == 0 )
    {
        // Closed, nothing to do
    }
}

#pragma mark - View lifecycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_imageView release];
    [_alertTitle release];
    [_alertMessage release];
    self.alertView = nil;
    [super dealloc];


}

@end