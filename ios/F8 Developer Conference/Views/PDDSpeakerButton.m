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

#import "PDDSpeakerButton.h"
#import "PDDSpeaker.h"
#import "PDDPhotoView.h"

#import "UIColor+PDD.h"
#import "UILabel+PDD.h"
#import "UIFont+PDD.h"

#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

@interface PDDSpeakerButton ()
@property (weak, nonatomic) PDDPhotoView *photoView;
@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UILabel *companyLabel;
@end

@implementation PDDSpeakerButton

- (id)initWithSpeaker:(PDDSpeaker *)speaker {
    if (self = [super initWithFrame:CGRectZero]) {
        _speaker = speaker;
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.backgroundColor = [UIColor pddMainBackgroundColor];

        PDDPhotoView *photoView = [[PDDPhotoView alloc] init];
        [self addSubview:photoView];
        self.photoView = photoView;

        UIView *detailView = [[UIView alloc] init];
        detailView.userInteractionEnabled = NO;
        [detailView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:detailView];

        UILabel *nameLabel = [UILabel autolayoutLabel];
        nameLabel.font = [UIFont pddH2];
        nameLabel.textColor = [UIColor pddTextColor];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [detailView addSubview:nameLabel];
        self.nameLabel = nameLabel;

        UILabel *companyLabel = [UILabel autolayoutLabel];
        companyLabel.textColor = [UIColor pddTextColor];
        companyLabel.font = [UIFont pddBody];
        companyLabel.preferredMaxLayoutWidth = 200;
        companyLabel.numberOfLines = 0;
        [detailView addSubview:companyLabel];
        self.companyLabel = companyLabel;

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[photoView(50)]-10-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(photoView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[photoView(50)]-[detailView]-5-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(photoView, detailView)]];
        [detailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nameLabel][companyLabel]|"
                                                                     options:NSLayoutFormatAlignAllLeft
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(nameLabel, companyLabel)]];

        // Fill in data
        if (!((id)speaker == [NSNull null])) {
            self.photoView.file = speaker.photo;
            [self.photoView loadInBackground];
            self.nameLabel.text = speaker.name;
            self.companyLabel.text = [NSString stringWithFormat:@"%@ @ %@", speaker.title, speaker.company];
        }
    }
    return self;
}

@end
