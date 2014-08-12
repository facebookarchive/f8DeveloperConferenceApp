/**
 * Copyright 2014 Facebook, Inc.
 *
 * You are hereby granted a non-exclusive, worldwide, royalty-free license to
 * use, copy, modify, and distribute this software in source code or binary
 * form for use in connection with the web services and APIs provided by
 * Facebook.
 *
 * As with any software that integrates with the Facebook platform, your use
 * of this software is subject to the Facebook Developer Principles and
 * Policies [http://developers.facebook.com/policy/]. This copyright notice
 * shall be included in all copies or substantial portions of the software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */

#import "UIColor+PDD.h"

@implementation UIColor (PDD)

// actual colors

+ (UIColor *)pddGreyBlueColor {
    return [[self class] pddColorWithRed:115.0f green:151.0f blue:168.0f];
}

+ (UIColor *)pddTextColor {
    return [[self class] pddColorWithRed:255.0f green:255.0f blue:255.0f];
}

+ (UIColor *)pddSubtitleColor {
    return [[self class] pddColorWithRed:255.0f green:255.0f blue:255.0f];
}

+ (UIColor *)pddBackgroundColor {
    return [[self class] pddColorWithRed:222.0f green:233.0f blue:236.0f];
}

+ (UIColor *)pddBreakTextColor {
    return [[self class] pddColorWithRed:100.0f green:122.0f blue:140.0f];
}

+ (UIColor *)pddOverlayColor {
    return [[self class] pddColorWithRed:152.0f green:153.0f blue:153.0f alpha:0.5f];
}

+ (UIColor *)pddContentBackgroundColor {
    return [[self class] pddColorWithRed:43.0f green:43.0f blue:43.0f];
}

+ (UIColor *)pddMainBackgroundColor {
    return [[self class] pddColorWithRed:43.0f green:43.0f blue:43.0f];
}

+ (UIColor *)pddSeparatorColor {
    return [[self class] pddColorWithRed:68.0f green:66.0f blue:66.0f];
}

+ (UIColor *)pddSegmentOffColor {
    return [[self class] pddColorWithRed:33.0f green:32.0f blue:31.0f];
}

+ (UIColor *)pddNavyColor {
    return [[self class] pddColorWithRed:46.0f green:69.0f blue:81.0f];
}

+ (UIColor *)pddLightGretColor {
    return [[self class] pddColorWithRed:213.0f green:213.0f blue:213.0f];
}

+ (UIColor *)pddParseBlueColor {
    return [[self class] colorWithHex:0x0076B0];
}

+ (UIColor *)pddAccentBlueColor {
    return [[self class] pddColorWithRed:0.0f green:156.0f blue:235.0f];
}

+ (UIColor *)pddOrangeColor {
    return [[self class] pddColorWithRed:255.0f green:147.0f blue:0.0f];
}

+ (UIColor *)colorWithHex:(long)hexColor {
    CGFloat red = ((CGFloat)((hexColor & 0xFF0000) >> 16))/255.0f;
    CGFloat green = ((CGFloat)((hexColor & 0xFF00) >> 8))/255.0f;
    CGFloat blue = ((CGFloat)(hexColor & 0xFF))/255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

+ (UIColor *)colorWithRGB:(NSArray *)arrayColor {
    CGFloat redColor = [arrayColor[0] floatValue];
    CGFloat greeenColor = [arrayColor[1] floatValue];
    CGFloat blueColor = [arrayColor[2] floatValue];
    return [[self class] pddColorWithRed:redColor green:greeenColor blue:blueColor alpha:1.0f];
}

+ (UIColor *)colorWithRGB:(NSArray *)arrayColor alpha:(CGFloat)alpha {
    return [[self class] colorWithRGB:arrayColor alpha:alpha];
}

#pragma mark - Private methods

+ (UIColor *)pddColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [[self class] pddColorWithRed:red green:green blue:blue alpha:1.0f];
}

+ (UIColor *)pddColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
