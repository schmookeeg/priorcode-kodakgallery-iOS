//
//  GradientButton.h
//  MobileApp
//
//  Created by mikeb on 9/14/11.
//  Copyright 2011 Kodak Imaging Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface GradientButton : UIButton
{

}

@property ( nonatomic, retain ) UIColor *_highColor;
@property ( nonatomic, retain ) UIColor *_lowColor;
@property ( nonatomic, retain ) CAGradientLayer *gradientLayer;

- (void)setHighColor:(UIColor *)color;

- (void)setLowColor:(UIColor *)color;

@end
