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

#import "PDDWelcomeCell.h"
#import "UIColor+PDD.h"
#import "UILabel+PDD.h"
#import "UIFont+PDD.h"

@interface PDDWelcomeCell ()
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) NSDictionary *info;
@end

@implementation PDDWelcomeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor pddContentBackgroundColor];
        self.clipsToBounds = YES;
        
        self.textLabel.font = [UIFont pddH3];
        self.textLabel.textColor = [UIColor pddTextColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        
        UILabel *titleLabel = [UILabel autolayoutLabel];
        titleLabel.font = [UIFont pddH2];
        titleLabel.textColor = [UIColor pddTextColor];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *contentLabel = [UILabel autolayoutLabel];
        contentLabel.font = [UIFont pddBody];
        contentLabel.textColor = [UIColor pddSubtitleColor];
        [self addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel, contentLabel);
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-15-[titleLabel]-8-[contentLabel]|"
                              options:NSLayoutFormatAlignAllLeft
                              metrics:nil
                              views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[titleLabel]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // do nothing, short-circuit super behavior
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    // do nothing, short-circuit super behavior
}

#pragma mark - Public methods
- (void) setInfo:(NSDictionary *)info {
    _info = info;
    self.titleLabel.hidden = NO;
    self.contentLabel.hidden = NO;
    self.textLabel.hidden = YES;
    self.titleLabel.text = self.info[@"title"];
    self.contentLabel.text = self.info[@"content"];
}

- (void) setTextOnly:(NSString *)text {
    self.titleLabel.hidden = YES;
    self.contentLabel.hidden = YES;
    self.textLabel.hidden = NO;
    self.textLabel.text = text;
}

@end
