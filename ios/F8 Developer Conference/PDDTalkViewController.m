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

#import "PDDTalkViewController.h"
#import "PDDTalk.h"

#import "PDDContentView.h"
#import "PDDTalkView.h"
#import "PDDSpeakerButton.h"

#import "PDDVideoViewController.h"

@interface PDDTalkViewController () <UIGestureRecognizerDelegate>
@property (strong, nonatomic) PDDTalk *talk;
@property (strong, nonatomic) PDDVideoViewController *videoViewController;
@end

@implementation PDDTalkViewController

#pragma mark - Initialization methods
- (id)initWithTalk:(PDDTalk *)talk atPageIndex:(NSInteger)pageIndex {
    self = [super init];
    if (self) {
        _talk = talk;
        _pageIndex = pageIndex;
    }
    return self;
}

- (id)initWithTalk:(PDDTalk *)talk {
    return [self initWithTalk:talk atPageIndex:0];
}

#pragma mark - View lifecycle methods
- (void)loadView {
    PDDContentView *contentView = [[PDDContentView alloc] init];
    PDDTalkView *talkView = [[PDDTalkView alloc] initWithTalk:self.talk];
    
    // Set up the video play tap handlers
    [talkView.videoPlayButton addTarget:self action:@selector(_playVideo:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *videoPlayTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_playVideo:)];
    videoPlayTapGestureRecognizer.numberOfTapsRequired = 1;
    [talkView.videoView addGestureRecognizer:videoPlayTapGestureRecognizer];
    videoPlayTapGestureRecognizer.delegate = self;
    
    // Set up favorite tap handlers
    [talkView.favoriteButton addTarget:self action:@selector(_favorite:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *favoriteTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_favorite:)];
    favoriteTapGestureRecognizer.numberOfTapsRequired = 1;
    [talkView.favoriteView addGestureRecognizer:favoriteTapGestureRecognizer];
    favoriteTapGestureRecognizer.delegate = self;
    
    // Close button click handler
    [talkView.closeButton addTarget:self action:@selector(_close:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addScrollView:talkView];
    
    self.talkView = talkView;
    self.view = contentView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Talk Details";
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// Since we allow rotation in the video view
// controller, presented from here, allow
// an interface reset.
-(BOOL)shouldAutorotate {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Private methods
- (void)_favorite:(id)sender {
    BOOL newFavorite = ![self.talk isFavorite];
    [self.talk toggleFavorite:newFavorite];
    [self.talkView toggleFavorite:newFavorite];
}

- (void)_close:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_playVideo:(id)sender {
    if (self.talk.videoID) {
        if (!self.videoViewController) {
            self.videoViewController = [[PDDVideoViewController alloc] initWithVideo:self.talk.videoID];
            [self presentViewController:self.videoViewController animated:YES completion:^{
                [self.videoViewController setInitialVideoPresentation:NO];
            }];
        } else {
            [self.videoViewController setInitialVideoPresentation:YES];
            [self presentViewController:self.videoViewController animated:YES completion:^{
                [self.videoViewController setInitialVideoPresentation:NO];
            }];
        }
    }
}

@end
