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

#import "PDDActivityView.h"
#import "UIFont+PDD.h"
#import "UIColor+PDD.h"
#import "UILabel+PDD.h"

@interface PDDActivityView ()
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end
@implementation PDDActivityView

- (id)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
        
        UIView *contentView = [[UIView alloc] init];
        [contentView  setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        UILabel *label = [UILabel autolayoutLabel];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont pddBody];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.hidden = YES;
        [contentView addSubview:label];
        self.label = label;
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [activityIndicator setHidesWhenStopped:YES];
        
        [contentView addSubview:activityIndicator];
        self.activityIndicator = activityIndicator;
        
        [self addSubview:contentView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(label, activityIndicator);
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"|-10-[label(200)]-10-|"
                              options:0
                              metrics:nil
                              views:views]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"|-10-[activityIndicator]-10-|"
                              options:0
                              metrics:nil
                              views:views]];
        [self addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:|-10-[activityIndicator]-15-[label]-10-|"
                                  options:NSLayoutFormatAlignAllCenterX
                                  metrics:nil
                                  views:views]];
        
        // Center horizontally
        [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView
                                                         attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        // Center vertically
        [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView
                                                         attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    return self;
}

#pragma mark - Public methods
- (void)startActivity {
    [self.activityIndicator startAnimating];
    [self.label setHidden:NO];
}

- (void)stopActivity {
    if ([self.activityIndicator isAnimating]) {
        [self.activityIndicator stopAnimating];
    }
    [self.label setHidden:YES];
}

- (void)setLabelText:(NSString *)text {
    self.label.text = text;
}

@end
