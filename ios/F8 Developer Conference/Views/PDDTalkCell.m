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

#import "PDDTalkCell.h"
#import "PDDRoom.h"
#import "PDDSlot.h"
#import "PDDSpeaker.h"
#import "PDDFavoriteButton.h"
#import "PDDPhotoView.h"

#import "UIColor+PDD.h"
#import "UILabel+PDD.h"
#import "UIFont+PDD.h"

@interface PDDTalkCell ()
@property (weak, nonatomic) UIView *talkView;
@property (weak, nonatomic) PFImageView *photoImageView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *timeLabel;
@property (weak, nonatomic) UILabel *roomLabel;
@property (weak, nonatomic) UILabel *speakerLabel;

@property (weak, nonatomic) UIView *breakView;
@property (weak, nonatomic) PFImageView *breakIcon;
@property (weak, nonatomic) UILabel *breakTitleLabel;
@property (weak, nonatomic) UILabel *breakTimeLabel;

- (void)_configureAsTalk;
- (void)_configureAsBreak;
@end

@implementation PDDTalkCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor pddContentBackgroundColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = [UIColor pddSeparatorColor];
        
        self.clipsToBounds = YES;

        UIView *talkView = [[UIView alloc] initWithFrame:self.bounds];
        talkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        PDDPhotoView *imageView = [[PDDPhotoView alloc] init];
        [talkView addSubview:imageView];
        self.photoImageView = imageView;

        UIView *detailView = [[UIView alloc] init];
        [detailView setTranslatesAutoresizingMaskIntoConstraints:NO];

        UILabel *titleLabel = [UILabel autolayoutLabel];
        titleLabel.font = [UIFont pddH2];
        titleLabel.textColor = [UIColor pddTextColor];
        [detailView addSubview:titleLabel];
        self.titleLabel = titleLabel;

        UILabel *timeLabel = [UILabel autolayoutLabel];
        timeLabel.font = [UIFont pddH3];
        timeLabel.textColor = [UIColor pddSubtitleColor];
        timeLabel.alpha = 0.6;
        [detailView addSubview:timeLabel];
        self.timeLabel = timeLabel;

        UILabel *roomLabel = [UILabel autolayoutLabel];
        roomLabel.font = [UIFont pddH3];
        roomLabel.textColor = [UIColor pddSubtitleColor];
        roomLabel.alpha = 0.6;
        [detailView addSubview:roomLabel];
        self.roomLabel = roomLabel;

        UILabel *speakerLabel = [UILabel autolayoutLabel];
        speakerLabel.font = [UIFont pddH3];
        speakerLabel.textColor = [UIColor pddSubtitleColor];
        speakerLabel.alpha = 0.6;
        [detailView addSubview:speakerLabel];
        self.speakerLabel = speakerLabel;
        
        [talkView addSubview:detailView];

        PDDFavoriteButton *favoriteButton = [[PDDFavoriteButton alloc] init];
        [favoriteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [talkView addSubview:favoriteButton];
        self.favoriteButton = favoriteButton;

        [self.contentView addSubview:talkView];
        self.talkView = talkView;

        NSDictionary *views = NSDictionaryOfVariableBindings(imageView, detailView, titleLabel, timeLabel, roomLabel, favoriteButton, speakerLabel);
        [detailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[timeLabel]-2-[titleLabel]-2-[speakerLabel]|"
                                                                           options:NSLayoutFormatAlignAllLeft
                                                                           metrics:nil
                                                                             views:views]];
        [detailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[roomLabel]-2-[titleLabel]-2-[speakerLabel]|"
                                                                           options:NSLayoutFormatAlignAllLeft
                                                                           metrics:nil
                                                                             views:views]];
        [detailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[titleLabel]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views]];
        [talkView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[imageView(44)]-10-[detailView]-(>=10)-[favoriteButton(37)]-8-|"
                                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                                 metrics:nil
                                                                                   views:views]];
        // Mugh. Explicit size-setting, because AutoLayout is annoying
        [talkView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[imageView(44)]"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        [talkView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[favoriteButton(37)]"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];

        // Now set up the layout for Break cells
        UIView *breakView = [[UIView alloc] initWithFrame:self.bounds];
        breakView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        PFImageView *breakIcon = [[PFImageView alloc] init];
        [breakIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
        [breakView addSubview:breakIcon];
        self.breakIcon = breakIcon;

        UIView *breakDetailView = [[UIView alloc] init];
        [breakDetailView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        UILabel *breakTitleLabel = [UILabel autolayoutLabel];
        breakTitleLabel.font = [UIFont pddH2];
        breakTitleLabel.textColor = [UIColor pddTextColor];
        breakTitleLabel.textAlignment = NSTextAlignmentLeft;
        [breakDetailView addSubview:breakTitleLabel];
        self.breakTitleLabel = breakTitleLabel;

        UILabel *breakTimeLabel = [UILabel autolayoutLabel];
        breakTimeLabel.font = [UIFont pddH3];
        breakTimeLabel.textColor = [UIColor pddSubtitleColor];
        [breakDetailView addSubview:breakTimeLabel];
        self.breakTimeLabel = breakTimeLabel;
        
        [breakView addSubview:breakDetailView];
        
        [self.contentView addSubview:breakView];
        self.breakView = breakView;
        
        
        NSDictionary *breakViews = NSDictionaryOfVariableBindings(breakIcon, breakTitleLabel, breakTimeLabel, breakDetailView);
        
        [breakDetailView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[breakTimeLabel]-2-[breakTitleLabel]|"
                                                                           options:NSLayoutFormatAlignAllLeft
                                                                           metrics:nil
                                                                             views:breakViews]];
        
        [breakView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[breakIcon(40)]-12-[breakDetailView]|"
                                                                         options:NSLayoutFormatAlignAllCenterY
                                                                         metrics:nil
                                                                           views:breakViews]];

        [breakView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-17-[breakIcon(45)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:breakViews]];
    }
    return self;
}

- (void)prepareForReuse {
    self.photoImageView.image = nil;
}

#pragma mark - PDDTalkCell methods
- (void)setTalk:(PDDTalk *)talk {
    _talk = talk;
    
    if (talk.alwaysFavorite) {
        [self _configureAsBreak];
    } else {
        [self _configureAsTalk];
    }
    self.talkView.hidden = talk.alwaysFavorite;
    self.breakView.hidden = !talk.alwaysFavorite;
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
            }];
        }];
    }
}

#pragma mark - Private methods
- (void)_configureAsTalk {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = self.talk.title;
    self.timeLabel.text = [self.talk talkTime];
    self.roomLabel.text = self.talk.room.name;

    if ([self.talk.speakers count] > 0) {
        PDDSpeaker *firstSpeaker = [self.talk.speakers objectAtIndex:0];
        if (!((id)firstSpeaker == [NSNull null])) {
            [self.photoImageView setFile:firstSpeaker.photo];
            [self.photoImageView loadInBackground];
            self.speakerLabel.text = [NSString stringWithFormat:@"By %@", firstSpeaker.name];
        }
    }
    
    if (self.sectionType == kPDDTalkSectionByTrack) {
        self.roomLabel.hidden = YES;
    } else {
        self.timeLabel.hidden = YES;
    }
    self.favoriteButton.selected = [self.talk isFavorite];
    
    if (self.talk.isBreak) {
        self.favoriteButton.hidden = YES;
        self.photoImageView.hidden = YES;
    }
}

- (void)_configureAsBreak {
    self.breakTitleLabel.text = self.talk.title;
    self.breakTimeLabel.text = [self.talk talkTime];
    self.breakIcon.file = self.talk.icon;
    [self.breakIcon loadInBackground];
}

@end
