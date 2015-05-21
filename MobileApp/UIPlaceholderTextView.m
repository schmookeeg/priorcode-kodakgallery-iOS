//
//  UIPlaceholderTextView.m
//  MobileApp
//
//  @see http://stackoverflow.com/questions/1328638/placeholder-in-uitextview/1704469#1704469

#import "UIPlaceholderTextView.h"

@implementation UIPlaceholderTextView

@synthesize placeholderLabel;
@synthesize placeholder;
@synthesize placeholderColor;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[placeholderLabel release];
	placeholderLabel = nil;
	[placeholderColor release];
	placeholderColor = nil;
	[placeholder release];
	placeholder = nil;
	[super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setPlaceholder:@""];
	[self setPlaceholderColor:[UIColor lightGrayColor]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
	if ( ( self = [super initWithFrame:frame] ) )
	{
		[self setPlaceholder:@""];
		[self setPlaceholderColor:[UIColor lightGrayColor]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
	}
	return self;
}

- (void)textChanged:(NSNotification *)notification
{
	if ( [[self placeholder] length] == 0 )
	{
		return;
	}

	if ( [[self text] length] == 0 )
	{
		[[self viewWithTag:999] setAlpha:1];
	}
	else
	{
		[[self viewWithTag:999] setAlpha:0];
	}
}

- (void)drawRect:(CGRect)rect
{
	if ( [[self placeholder] length] > 0 )
	{
		if ( placeholderLabel == nil )
		{
			placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake( 9, 8, self.bounds.size.width - 18, 0 )];
			placeholderLabel.lineBreakMode = UILineBreakModeWordWrap;
			placeholderLabel.numberOfLines = 0;
			placeholderLabel.font = self.font;
			placeholderLabel.backgroundColor = [UIColor clearColor];
			placeholderLabel.textColor = self.placeholderColor;
			placeholderLabel.alpha = 0;
			placeholderLabel.tag = 999;
			[self addSubview:placeholderLabel];
		}

		placeholderLabel.text = self.placeholder;
		[placeholderLabel sizeToFit];
		[self sendSubviewToBack:placeholderLabel];
	}

	if ( [[self text] length] == 0 && [[self placeholder] length] > 0 )
	{
		[[self viewWithTag:999] setAlpha:1];
	}

	[super drawRect:rect];
}

@end
