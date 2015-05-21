//
//  CommentButtonView.h
//  MobileApp
//
//  Created by mikeb on 6/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommentButtonView : UIView
{
	UILabel *commentCounter;
}

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)selector;

- (void)setCommentCount:(NSNumber *)numberOfComments;

@end
