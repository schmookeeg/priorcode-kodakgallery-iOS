//
//  UIImage+Filtrr.h
//  fltr
//
//  Created by Omid Hashemi & Stefan Klefisch on 2/6/12.
//  Copyright (c) 2012 42dp. All rights reserved.
//  http://www.42dp.com
//  Github: https://github.com/OmidH/Filtrr
//
//  Based on Alex Michael's filtrr for Javascript (thanks for sharing Alex)
//  https://github.com/alexmic/filtrr
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

struct FieldPosition
{
    unsigned char one;
    unsigned char two;
    unsigned char three;
    unsigned char four;
};

typedef struct FieldPosition DataField;

struct anRGBA
{
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    unsigned char alpha;
};

typedef struct anRGBA RGBA;

enum EdgeTypes {
    simple = 0,
    sobel = 1,
    canny = 2
};

typedef enum EdgeTypes EdgeType;

static inline DataField DataFieldMake(int first, int second, int third, int fourth)
{
    DataField field;
    field.one = first;      field.two = second;
    field.three = third;    field.four = fourth;
    return field;
}

static inline RGBA RGBAMake(int r, int g, int b, int a)
{
    RGBA field;
    field.red = r;      field.blue = b;
    field.green = g;    field.alpha = a;
    return field;
}

@interface UIImage (Filtrr) 

- (float) safe:(int) i;
- (UIImage *) duplicate;

- (id) applyFiltrr:(struct anRGBA (^)(int r, int g, int b, int a))fn;
- (id) applyFiltrrByStep:(int) step 
                 ShiftIn:(DataField)shiftIn 
                ShiftOut:(DataField)shiftOut 
                Callback:(struct anRGBA (^)(int r, int g, int b, int a))fn;

- (id) convolve:(NSArray *) kernel;
- (id) edgeDetection:(EdgeType)edgetype;
- (id) adjustRedChannel:(float) rS GreenChannel:(float) gS BlueChannel:(float) bS;
- (id) brightnessByFactor:(float) t;
- (id) fillRedChannel:(float)rF GreenChannel:(float) gF BlueChannel:(float) bF;
- (id) opacityByFactor:(float) o;
- (id) saturationByFactor:(float) t;
- (id) thresholdByFactor:(float) t;
- (id) posterizeByLevel:(float) level;
- (id) gammaByValue:(float) value;
- (id) negative;
- (id) grayScale;
- (id) bump;
- (id) tintWithMinRGB:(RGBA)minRGB MaxRGB:(RGBA)maxRGB;
- (id) maskRedChannel:(int)mR GreenChannel:(int) mG BlueChannel:(int) mB;
- (id) sepia;
- (id) biasByFactor:(float) val;
- (id) contrastByFactor:(float) val;
- (id) blur;
- (id) sharpen;
- (id) gaussianBlur;

- (id) applyBlend:(UIImage *)topImage CallBack: (struct anRGBA (^)(RGBA top, RGBA bottom))fn;
- (id) multiply:(UIImage *)topImage;
- (id) screen:(UIImage *)topFltr;
- (id) overlay:(UIImage *)topFltr;
- (id) difference:(UIImage *)topFltr;
- (id) addition:(UIImage *)topFltr;
- (id) exclusion:(UIImage *)topFltr;
- (id) softLight:(UIImage *)topFltr;

- (float) calc_bias:(float) f Bias:(float) bi;
- (float) calc_contrast:(float) f contrast:(float) c;
- (float) calc_overlay:(float)b other:(float) t;
- (float) calc_softlight:(float)b other:(float) t;

@end