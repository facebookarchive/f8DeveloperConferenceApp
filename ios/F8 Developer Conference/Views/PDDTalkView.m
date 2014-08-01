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

#import "PDDTalkView.h"
#import "PDDTalk.h"
#import "PDDRoom.h"
#import "PDDSpeaker.h"
#import "PDDFavoriteButton.h"
#import "PDDSpeakerButton.h"
#import "PDDCloseButton.h"

#import "UIColor+PDD.h"
#import "UILabel+PDD.h"
#import "UIFont+PDD.h"

@interface PDDTalkView()
@property (nonatomic, weak) UILabel *favoriteLabel;
@end

@implementation PDDTalkView 

#pragma mark - Initialization
- (id)initWithTalk:(PDDTalk *)talk {
    if (self = [super initWithFrame:CGRectZero]) {
        // Avoids the background color showing when
        // the talk is pulled down.
        self.bounces = NO;
        // Add some extra space at the bottom since we're
        // not allowing a vertical bounce.
        self.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
        
        UIView *headerView = [[UIView alloc] init];
        [headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        if (talk.room.displayColor) {
            headerView.backgroundColor = [UIColor colorWithRGB:talk.room.displayColor];
        } else {
            headerView.backgroundColor = [UIColor pddNavyColor];
        }
        
        PDDCloseButton *closeButton = [[PDDCloseButton alloc] init];
        [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [headerView addSubview:closeButton];
        self.closeButton = closeButton;
        
        UILabel *titleLabel = [UILabel autolayoutLabel];
        titleLabel.font = [UIFont pddH1];
        titleLabel.textColor = [UIColor pddTextColor];
        titleLabel.preferredMaxLayoutWidth = 220;
        titleLabel.numberOfLines = 0;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [headerView addSubview:titleLabel];
        
        UILabel *timeLabel = [UILabel autolayoutLabel];
        timeLabel.font = [UIFont pddH3];
        timeLabel.textColor = [UIColor pddSubtitleColor];
        [headerView addSubview:timeLabel];
        
        UILabel *abstractLabel = [UILabel autolayoutLabel];
        abstractLabel.font = [UIFont pddBody];
        abstractLabel.textColor = [UIColor pddTextColor];
        abstractLabel.preferredMaxLayoutWidth = 280;
        abstractLabel.numberOfLines = 0;
        [headerView addSubview:abstractLabel];
        
        // Video view
        UIView *videoView = [[UIView alloc] init];
        [videoView setTranslatesAutoresizingMaskIntoConstraints:NO];
        videoView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
        UIView *videoContentView = [[UIView alloc] init];
        videoContentView.backgroundColor = [UIColor clearColor];
        [videoContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        // Video button
        UIButton *videoPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [videoPlayButton setImage:[UIImage imageNamed:@"video"] forState:UIControlStateNormal];
        [videoPlayButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [videoPlayButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [videoContentView addSubview:videoPlayButton];
        self.videoPlayButton = videoPlayButton;
        // Video label
        UILabel *videoLabel = [UILabel autolayoutLabel];
        videoLabel.font = [UIFont pddBody];
        videoLabel.textColor = [UIColor pddTextColor];
        videoLabel.text = @"Watch the Video";
        [videoContentView addSubview:videoLabel];
        // Add content view to video view
        [videoView addSubview:videoContentView];
        self.videoView = videoView;
        [headerView addSubview:videoView];
        
        // Favorite view
        UIView *favoriteView = [[UIView alloc] init];
        [favoriteView setTranslatesAutoresizingMaskIntoConstraints:NO];
        favoriteView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
        UIView *favoriteContentView = [[UIView alloc] init];
        favoriteContentView.backgroundColor = [UIColor clearColor];
        [favoriteContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        // Favorite button
        PDDFavoriteButton *favoriteButton = [[PDDFavoriteButton alloc] init];
        [favoriteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [favoriteContentView addSubview:favoriteButton];
        self.favoriteButton = favoriteButton;
        // Favorite label
        UILabel *favoriteLabel = [UILabel autolayoutLabel];
        favoriteLabel.font = [UIFont pddBody];
        favoriteLabel.textColor = [UIColor pddTextColor];
        [favoriteContentView addSubview:favoriteLabel];
        self.favoriteLabel = favoriteLabel;
        [favoriteView addSubview:favoriteContentView];
        self.favoriteView = favoriteView;
        [headerView addSubview:favoriteView];
        
        [self addSubview:headerView];
        
        // Video play button
        [videoContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[videoPlayButton(37)][videoLabel]|"
                                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                                    metrics:nil
                                                                                      views:NSDictionaryOfVariableBindings(videoPlayButton, videoLabel)]];
        [videoContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[videoPlayButton(37)]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:NSDictionaryOfVariableBindings(videoPlayButton)]];
        
        
        [videoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-70-[videoContentView]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(videoContentView)]];
        
        [videoView addConstraint:[NSLayoutConstraint constraintWithItem:videoContentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                                    toItem:videoView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [videoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[videoContentView]-5-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(videoContentView)]];
        
        // Favorite button
        [favoriteContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[favoriteButton(37)][favoriteLabel]|"
                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(favoriteButton, favoriteLabel)]];
        [favoriteContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[favoriteButton(37)]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(favoriteButton)]];
        
        [favoriteView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-70-[favoriteContentView]"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:NSDictionaryOfVariableBindings(favoriteContentView)]];

        [favoriteView addConstraint:[NSLayoutConstraint constraintWithItem:favoriteContentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                            toItem:favoriteView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [favoriteView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[favoriteContentView]-5-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(favoriteContentView)]];
        
        [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[titleLabel]-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(titleLabel)]];
        
        [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[closeButton(37)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(closeButton)]];
        
        [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[closeButton(37)]-(20)-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(closeButton)]];

        if (talk.videoID) {
            [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-37-[timeLabel]-[titleLabel]-[abstractLabel]-15-[videoView]-2-[favoriteView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(titleLabel, timeLabel, abstractLabel, videoView, favoriteView)]];
        } else {
            [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-37-[timeLabel]-[titleLabel]-[abstractLabel]-15-[favoriteView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(titleLabel, timeLabel, abstractLabel, favoriteView)]];
        }
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[titleLabel]-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(titleLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[timeLabel]-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(timeLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[abstractLabel]-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(abstractLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[videoView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(videoView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[favoriteView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(favoriteView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[headerView(320)]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(headerView)]];
        

        // Set Talk data
        titleLabel.text = talk.title;
        timeLabel.text = [talk talkTime];
        abstractLabel.text = talk.abstract;
        self.favoriteView.hidden = talk.alwaysFavorite || talk.isBreak;
        self.favoriteButton.selected = [talk isFavorite];
        if ([talk isFavorite]) {
            favoriteLabel.text = @"Remove from My Schedule";
        } else {
            favoriteLabel.text = @"Save to My Schedule";
        }
        
        self.videoView.hidden = (talk.videoID == nil);
        
        NSMutableDictionary *viewDict = [NSMutableDictionary dictionaryWithDictionary:NSDictionaryOfVariableBindings(headerView)];
        __block NSMutableArray *speakerFormats = [NSMutableArray array];
        [talk.speakers enumerateObjectsUsingBlock:^(PDDSpeaker *speaker, NSUInteger idx, BOOL *stop) {
            PDDSpeakerButton *button = [[PDDSpeakerButton alloc] initWithSpeaker:speaker];
            [self addSubview:button];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[button]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(button)]];
            NSString *idString = [NSString stringWithFormat:@"speaker%lu", (unsigned long)idx];
            viewDict[idString] = button;
            [speakerFormats addObject:[NSString stringWithFormat:@"[%@]", idString]];
        }];
        self.speakerButtons = [[viewDict allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
            return ![obj isEqual:headerView];
        }]];
        NSString *formatString = [NSString stringWithFormat:@"V:|[headerView]-20-%@|", [speakerFormats componentsJoinedByString:@""]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:viewDict]];
    }
    return self;
}

#pragma mark - Public methods
- (void)toggleFavorite:(BOOL)isFavorite {
    BOOL previousFavoriteSelection = self.favoriteButton.selected;
    [self.favoriteButton setSelected:isFavorite];
    if (previousFavoriteSelection != self.favoriteButton.selected) {        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:.07 animations:^{
            CATransform3D transform = CATransform3DMakeScale(.8, .8, 1);
            
            self.favoriteButton.layer.transform = CATransform3DTranslate(transform, 1, 1, 1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.07 animations:^{
                self.favoriteButton.layer.transform = CATransform3DIdentity;
                if (isFavorite) {
                    self.favoriteLabel.text = @"Remove from My Schedule";
                } else {
                    self.favoriteLabel.text = @"Save to My Schedule";
                }
            }];
        }];
    }
}

@end
