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

#import "UIView+PDD.h"

@implementation UIView (PDD)

+ (BOOL)shouldAdjustForEarlierIOSVersions {
    return floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1;
}

- (void)addForegroundMotionEffects {
    if (![[self class] motionEffectsAvailable]) {
        return;
    }

    UIInterpolatingMotionEffect *foregroundMotionXEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    foregroundMotionXEffect.maximumRelativeValue = [self foregroundMotionEffectMaximumRelativeValue];
    foregroundMotionXEffect.minimumRelativeValue = [self foregroundMotionEffectMinimumRelativeValue];
    [self addMotionEffect:foregroundMotionXEffect];
    
    UIInterpolatingMotionEffect *foregroundMotionYEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    foregroundMotionYEffect.maximumRelativeValue = [self foregroundMotionEffectMaximumRelativeValue];
    foregroundMotionYEffect.minimumRelativeValue = [self foregroundMotionEffectMinimumRelativeValue];
    [self addMotionEffect:foregroundMotionYEffect];
}

- (void)addBackgroundMotionEffects {
    if (![[self class] motionEffectsAvailable]) {
        return;
    }

    UIInterpolatingMotionEffect *backgroundMotionXEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    backgroundMotionXEffect.maximumRelativeValue = [self backgroundMotionEffectMaximumRelativeValue];
    backgroundMotionXEffect.minimumRelativeValue = [self backgroundMotionEffectMinimumRelativeValue];
    [self addMotionEffect:backgroundMotionXEffect];
    
    UIInterpolatingMotionEffect *backgroundMotionYEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    backgroundMotionYEffect.maximumRelativeValue = [self backgroundMotionEffectMaximumRelativeValue];
    backgroundMotionYEffect.minimumRelativeValue = [self backgroundMotionEffectMinimumRelativeValue];
    [self addMotionEffect:backgroundMotionYEffect];
}

#pragma mark - Private methods
+ (BOOL)motionEffectsAvailable {
    if (NSClassFromString(@"UIInterpolatingMotionEffect")) {
        return YES;
    }
    return NO;
}

- (void)addMotionEffectsWithDelta:(NSNumber *)delta {
    if (![[self class] motionEffectsAvailable]) {
        return;
    }

    UIInterpolatingMotionEffect *holographicMotionXEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    holographicMotionXEffect.maximumRelativeValue = delta;
    holographicMotionXEffect.minimumRelativeValue = @(-1 * [delta floatValue]);
    [self addMotionEffect:holographicMotionXEffect];
    
    UIInterpolatingMotionEffect *holographicMotionYEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    holographicMotionYEffect.maximumRelativeValue = @(-1 * [delta floatValue]);
    holographicMotionYEffect.minimumRelativeValue = delta;
    [self addMotionEffect:holographicMotionYEffect];
}

- (NSNumber *)foregroundMotionEffectMinimumRelativeValue {
    return @(-10);
}

- (NSNumber *)foregroundMotionEffectMaximumRelativeValue {
    return @10;
}

- (NSNumber *)backgroundMotionEffectMinimumRelativeValue {
    return @40;
}

- (NSNumber *)backgroundMotionEffectMaximumRelativeValue {
    return @(-40);
}

@end
