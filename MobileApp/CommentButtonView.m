//
//  CommentButtonView.m
//  MobileApp
//
//  Created by Dev on 6/21/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import "CommentButtonView.h"


@implementation CommentButtonView

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)selector
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		// Initialization code
		UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[commentButton setFrame:frame];
		[commentButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

		UIImageView *commentIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:kAssetCommentsIcon]] autorelease];
		[commentIcon setFrame:frame];

		CGRect labelFrame = CGRectMake( 4.0, 8.0, 19.0, 12.0 );
		commentCounter = [[UILabel alloc] initWithFrame:labelFrame];
		[commentCounter setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
		[commentCounter setBackgroundColor:[UIColor clearColor]];
		[commentCounter setTextColor:[UIColor blackColor]];
		[commentCounter setTextAlignment:UITextAlignmentCenter];
		[commentCounter setText:@"0"];

		[commentButton addSubview:commentIcon];
		[commentButton addSubview:commentCounter];

		[self addSubview:commentButton];
//		[self addSubview:commentIcon];
//		[self addSubview:commentCounter];

	}
	return self;
}

- (void)dealloc
{
	[commentCounter release];

	[super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setCommentCount:(NSNumber *)numberOfComments
{
	NSString *val = [numberOfComments stringValue];
	if ( [val length] == 1 )
	{
		val = [NSString stringWithFormat:@" %@", val];
	}


	[commentCounter setText:val];
}

@end
