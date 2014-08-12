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

#import "PDDPhotoView.h"

#import <QuartzCore/QuartzCore.h>
#import "UIColor+PDD.h"

@interface PDDPhotoView ()
- (void)_setImage:(UIImage *)image inRect:(CGRect)rect;
@end

@implementation PDDPhotoView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return self;
}

- (void)layoutSubviews {
    // redraw if necessary
    [self _setImage:self.image inRect:self.bounds];
}

- (void)setImage:(UIImage *)image {
    [self _setImage:image inRect:self.bounds];
}

#pragma mark - Private
- (void)_setImage:(UIImage *)image inRect:(CGRect)rect {
    if (CGRectEqualToRect(rect, CGRectZero)) {
        [super setImage:image];
        return;
    }

    // Do the image processing here, so we don't have to rely on cornerRadius
    // and clipsToBounds
    CGFloat scale = [UIScreen mainScreen].scale;
    rect = CGRectMake(0, 0, rect.size.width * scale, rect.size.height * scale);

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, rect.size.height);
    CGContextScaleCTM(ctx, 1, -1);

    CGContextAddEllipseInRect(ctx, rect);
    CGContextClip(ctx);
    CGContextDrawImage(ctx, rect, image.CGImage);

    // Draw border
    CGContextSetLineWidth(ctx, scale * 2);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextStrokeEllipseInRect(ctx, rect);
    CGContextRestoreGState(ctx);
    UIImage *roundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [super setImage:roundImage];
}

@end
