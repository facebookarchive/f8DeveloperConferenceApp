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

#import "PDDEmptyView.h"
#import "UILabel+PDD.h"
#import "UIColor+PDD.h"
#import "UIFont+PDD.h"

@interface PDDEmptyView()
@property (strong, nonatomic) NSDictionary * data;
@property (weak, nonatomic) UIView *infoView;
@end

@implementation PDDEmptyView

-(id)initWithData:(NSDictionary*)data {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _data = data;
        self.backgroundColor = [UIColor pddContentBackgroundColor];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        UIView *infoView = [[UIView alloc] init];
        [infoView  setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        UILabel *titleLabel = [UILabel autolayoutLabel];
        titleLabel.font = [UIFont pddH1];
        titleLabel.textColor = [UIColor pddTextColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = self.data[@"title"];
        [infoView addSubview:titleLabel];
        
        UILabel *contentLabel = [UILabel autolayoutLabel];
        contentLabel.font = [UIFont pddBody];
        contentLabel.textColor = [UIColor pddTextColor];
        contentLabel.numberOfLines = 3;
        contentLabel.preferredMaxLayoutWidth = 260;
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.text = self.data[@"content"] ? self.data[@"content"] : @"";
        [infoView addSubview:contentLabel];
        
        self.infoView = infoView;
        [self addSubview:infoView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel, contentLabel);
        [infoView addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|[titleLabel]-15-[contentLabel]"
                              options:NSLayoutFormatAlignAllCenterX
                              metrics:nil
                              views:views]];
        [infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[titleLabel]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
        [infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[contentLabel]-20-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
        
        // Center horizontally
        [self addConstraint:[NSLayoutConstraint constraintWithItem:infoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                                        toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        // Center vertically
        [self addConstraint:[NSLayoutConstraint constraintWithItem:infoView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                                        toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
    }
    return self;
}


@end
