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

#import "PDDTalkHeaderView.h"

#import "UIView+PDD.h"
#import "UIColor+PDD.h"
#import "UILabel+PDD.h"
#import "UIFont+PDD.h"

@interface PDDTalkHeaderView()
@property (weak, nonatomic) UIView *summaryView;
@property (weak, nonatomic) UIView *separatorView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *timeLabel;
@property (weak, nonatomic) UILabel *descriptionLabel;
@end
@implementation PDDTalkHeaderView

#pragma mark - Initialization
- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 198.5)];
    if (self) {
        self.backgroundColor = [UIColor pddContentBackgroundColor];
        UIView *summaryView = [[UIView alloc] init];
        [summaryView setTranslatesAutoresizingMaskIntoConstraints:NO];
        summaryView.backgroundColor = [UIColor pddNavyColor];
        
        UILabel *titleLabel = [UILabel autolayoutLabel];
        titleLabel.font = [UIFont pddH1];
        [titleLabel setMinimumScaleFactor:[[UIFont pddH3] pointSize]/[[UIFont pddH1] pointSize]];
        [titleLabel setAdjustsFontSizeToFitWidth:YES];
        titleLabel.textColor = [UIColor pddTextColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [summaryView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *timeLabel = [UILabel autolayoutLabel];
        timeLabel.font = [UIFont pddBody];
        timeLabel.textColor = [UIColor pddTextColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel = timeLabel;
        [summaryView addSubview:timeLabel];
        
        [self addSubview:summaryView];
        self.summaryView = summaryView;
        
        UILabel *descriptionLabel = [UILabel autolayoutLabel];
        descriptionLabel.font = [UIFont pddBody];
        descriptionLabel.textColor = [UIColor pddTextColor];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.preferredMaxLayoutWidth = 260;
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:descriptionLabel];
        self.descriptionLabel = descriptionLabel;
        
        UIView *separatorView = [[UIView alloc] init];
        [separatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        separatorView.backgroundColor = [UIColor pddSeparatorColor];
        [self addSubview:separatorView];
        self.separatorView = separatorView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel, timeLabel);
        [summaryView addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:@"V:|[titleLabel][timeLabel]-30-|"
                                     options:NSLayoutFormatAlignAllCenterX
                                     metrics:nil
                                     views:views]];
        [summaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[titleLabel]-30-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:views]];
        [summaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[timeLabel]-30-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[summaryView(320)]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(summaryView)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[descriptionLabel]-20-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(descriptionLabel)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[separatorView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(separatorView)]];
        
        [summaryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[summaryView(91)]"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(summaryView)]];
        
        [descriptionLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[descriptionLabel(>=57)]"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(descriptionLabel)]];
        
        [separatorView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorView(0.5)]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(separatorView)]];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|[summaryView]-25-[descriptionLabel]-(>=25)-[separatorView]|"
                              options:NSLayoutFormatAlignAllCenterX
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(summaryView,descriptionLabel,separatorView)]];
        
    }
    return self;
}

-(id)initWithData:(NSDictionary*)data {
    self = [self init];
    if (self) {
        self.data = data;
    }
    return self;
}

#pragma mark - Accessor methods
-(void) setData:(NSDictionary*)data {
    _data = data;
    self.titleLabel.text = data[@"title"];
    self.timeLabel.text = data[@"time"];
    self.descriptionLabel.text = data[@"description"] ? data[@"description"] : @"";
}

#pragma mark - Public methods
- (void) setSummaryViewBackgroundColor:(UIColor *)color {
    self.summaryView.backgroundColor = color;
}

- (void) hideSeparatorView {
    self.separatorView.hidden = YES;
}

@end
