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

#import "PDDAlertCell.h"
#import "PDDMessage.h"

#import "UIColor+PDD.h"
#import "UILabel+PDD.h"
#import "UIFont+PDD.h"

@interface PDDAlertCell ()
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) NSDictionary *info;
@end

@implementation PDDAlertCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        UIView *alertView = [[UIView alloc] initWithFrame:self.bounds];
        alertView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UILabel *titleLabel = [UILabel autolayoutLabel];
        titleLabel.font = [UIFont pddH2];
        titleLabel.textColor = [UIColor pddTextColor];
        [alertView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *contentLabel = [UILabel autolayoutLabel];
        contentLabel.font = [UIFont pddBody];
        contentLabel.textColor = [UIColor pddSubtitleColor];
        [alertView addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        [self addSubview:alertView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel, contentLabel);
        [alertView addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-15-[titleLabel]-8-[contentLabel]|"
                              options:NSLayoutFormatAlignAllLeft
                              metrics:nil
                              views:views]];
        [alertView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[titleLabel]-40-|"
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
- (void) setAlert:(PDDMessage *)alert {
    _alert = alert;
    self.titleLabel.text = self.alert.title;
    self.contentLabel.text = self.alert.content;
    if (self.alert.isSurvey) {
        if (self.alert.isRead) {
            UIImageView *cellAccessortyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
            self.accessoryView = cellAccessortyImageView;
        } else {
            self.accessoryView = nil;
        }
    }
}

@end
