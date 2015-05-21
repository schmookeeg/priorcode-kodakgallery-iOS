//
//  UIPlaceholderTextView.h
//  MobileApp
//
//  @see http://stackoverflow.com/questions/1328638/placeholder-in-uitextview/1704469#1704469
//

#import <UIKit/UIKit.h>

@interface UIPlaceholderTextView : UITextView
{
	NSString *placeholder;
	UIColor *placeholderColor;

@private
	UILabel *placeholderLabel;
}

@property ( nonatomic, retain ) UILabel *placeholderLabel;
@property ( nonatomic, retain ) NSString *placeholder;
@property ( nonatomic, retain ) UIColor *placeholderColor;

- (void)textChanged:(NSNotification *)notification;

@end
