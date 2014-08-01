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

#import "PDDTrackView.h"
#import "PDDTalk.h"
#import "PDDRoom.h"

#import "UILabel+PDD.h"
#import "UIColor+PDD.h"
#import "UIFont+PDD.h"

@interface PDDTrackView() <UIGestureRecognizerDelegate>
@property (weak, nonatomic) PFImageView *trackIcon;
@property (weak, nonatomic) UIView *infoView;
@property (weak, nonatomic) UIImageView *timelineLeadingImageView;
@property (weak, nonatomic) UIImageView *timelineTrailingImageView;
@property (strong, nonatomic) PDDTalk *talk;
@end

@implementation PDDTrackView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        UIImage *timelineImage = [UIImage imageNamed:@"timeline"];
        
        UIImageView *timelineLeadingImageView = [[UIImageView alloc] initWithImage:timelineImage];
        [timelineLeadingImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:timelineLeadingImageView];
        self.timelineLeadingImageView = timelineLeadingImageView;
        
        UIImageView *timelineTrailingImageView = [[UIImageView alloc] initWithImage:timelineImage];
        [timelineTrailingImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:timelineTrailingImageView];
        self.timelineTrailingImageView = timelineTrailingImageView;
        
        UIView *infoView = [[UIView alloc] initWithFrame:self.bounds];
        infoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        PFImageView *trackIcon = [[PFImageView alloc] init];
        [trackIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
        trackIcon.userInteractionEnabled = YES;
        [infoView addSubview:trackIcon];
        self.trackIcon = trackIcon;
        
        [self addSubview:infoView];
        self.infoView = infoView;
        [self.infoView setAlpha:0.5];
        
        // Layout contraints
        CGFloat iconWidth = [[self class] _iconWidth];
        CGFloat iconHeight = [[self class] _iconHeight];
        CGFloat iconOffsetX = ([[self class] maxWidth] - iconWidth) / 2;
        CGFloat iconOffsetY = ([[self class] maxHeight] - iconHeight) / 2;
        CGFloat timelineImageHeight = timelineLeadingImageView.bounds.size.height;
        CGFloat timelineImageOffsetY = iconOffsetY + iconHeight / 2;
        
        NSDictionary *metrics = @{
                                  @"iconWidth": [NSNumber numberWithFloat:iconWidth],
                                  @"iconHeight": [NSNumber numberWithFloat:iconHeight],
                                  @"iconOffsetX": [NSNumber numberWithFloat:iconOffsetX],
                                  @"iconOffsetY": [NSNumber numberWithFloat:iconOffsetY],
                                  @"timelineImageHeight": [NSNumber numberWithFloat:timelineImageHeight],
                                  @"timelineImageOffsetY": [NSNumber numberWithFloat:timelineImageOffsetY],
                                  };
        
        NSDictionary *views = NSDictionaryOfVariableBindings(timelineLeadingImageView, timelineTrailingImageView, trackIcon, infoView);
        
        [infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-iconOffsetY-[trackIcon(iconHeight)]"
                                                                           options:NSLayoutFormatAlignAllCenterX
                                                                           metrics:metrics
                                                                             views:views]];
        [infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-iconOffsetX-[trackIcon(iconWidth)]"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:views]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-timelineImageOffsetY-[timelineLeadingImageView(timelineImageHeight)]"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-timelineImageOffsetY-[timelineTrailingImageView(timelineImageHeight)]"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[timelineLeadingImageView(iconOffsetX)]"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[timelineTrailingImageView(iconOffsetX)]|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        
        // Detect when track tapped
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_trackSelected:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGestureRecognizer];
        tapGestureRecognizer.delegate = self;
    }
    return self;
}

- (NSString *)description {
    if (self.talk.alwaysFavorite) {
        return self.talk.room.name;
    } else {
        return self.talk.title;
    }
}

#pragma mark - Public methods
- (void) setTalk:(PDDTalk *)talk {
    _talk = talk;
    
    if (talk.alwaysFavorite) {
        [self _configureAsBreak];
    } else {
        [self _configureAsTalk];
    }
}

- (void)setInitTrack {
    self.trackIcon.image = [UIImage imageNamed:@"welcome"];
    [self.infoView setAlpha:1.0];
}

-(void)selectTrack:(BOOL)selected {
    if (selected) {
        [self.infoView setAlpha:1.0];
    } else {
        [self.infoView setAlpha:0.5];
    }
}

+ (CGFloat)maxWidth {
    return 104.0;
}

+ (CGFloat)maxHeight {
    return 80.0;
}

- (void)trimTimelineImageLeading {
    self.timelineLeadingImageView.hidden = YES;
}

- (void)trimTimelineImageTrailing {
    self.timelineTrailingImageView.hidden = YES;
}

#pragma mark - Private methods
+ (CGFloat)_iconWidth {
    UIImage *trackImage = [UIImage imageNamed:@"welcome"];
    return trackImage.size.width;
}

+ (CGFloat)_iconHeight {
    UIImage *trackImage = [UIImage imageNamed:@"welcome"];
    return trackImage.size.height;
}

- (void)_configureAsTalk {
    self.trackIcon.file = self.talk.room.icon;
    [self.trackIcon loadInBackground];
}

- (void)_configureAsBreak {
    self.trackIcon.file = self.talk.icon;
    [self.trackIcon loadInBackground];
}

- (void)_trackSelected:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(trackSelectionDidChange:)]) {
        [self.delegate trackSelectionDidChange:self];
    }
}

@end
