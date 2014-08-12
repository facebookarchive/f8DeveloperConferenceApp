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

#import "PDDSpeakerView.h"
#import "PDDSpeaker.h"
#import "PDDSpeakerButton.h"
#import "PDDCloseButton.h"

#import "UIColor+PDD.h"
#import "UILabel+PDD.h"
#import "UIFont+PDD.h"

#import <Parse/Parse.h>

@implementation PDDSpeakerView

- (id)initWithSpeaker:(PDDSpeaker *)speaker {
    if (self = [super initWithFrame:CGRectZero]) {
        self.alwaysBounceVertical = YES;

        PDDCloseButton *closeButton = [[PDDCloseButton alloc] init];
        [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:closeButton];
        self.closeButton = closeButton;
        
        PDDSpeakerButton *speakerButton = [[PDDSpeakerButton alloc] initWithSpeaker:speaker];
        speakerButton.enabled = NO;
        [self addSubview:speakerButton];

        UILabel *bioLabel = [UILabel autolayoutLabel];
        bioLabel.preferredMaxLayoutWidth = 280;
        bioLabel.numberOfLines = 0;
        bioLabel.font = [UIFont pddBody];
        bioLabel.textColor = [UIColor pddTextColor];
        [self addSubview:bioLabel];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[speakerButton]-20-[bioLabel]-(>=10)-|"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(closeButton, speakerButton, bioLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[speakerButton]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(speakerButton)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[bioLabel]-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(bioLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[closeButton(37)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(closeButton)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[closeButton(37)]-(20)-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(closeButton)]];
        
        bioLabel.text = speaker.bio;
    }
    return self;
}

@end
