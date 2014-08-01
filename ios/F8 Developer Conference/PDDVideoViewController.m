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

#import "PDDVideoViewController.h"
#import "PDDActivityView.h"
#import "YTPlayerView.h"

@interface PDDVideoViewController () <YTPlayerViewDelegate>
@property (strong, nonatomic) NSString *video;
@property (weak, nonatomic) YTPlayerView *playerView;
@property (assign, nonatomic) BOOL isPlayerReady;
@property (strong, nonatomic) PDDActivityView *activityView;
@end

@implementation PDDVideoViewController

#pragma mark - Initialization methods
- (id)initWithVideo:(NSString *)video {
    self = [super init];
    if (self) {
        _video = video;
        _isPlayerReady = NO;
        _initialVideoPresentation = YES;
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void) loadView {
    UIView *view = [[UIView alloc] init];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    YTPlayerView *playerView = [[YTPlayerView alloc] init];
    [view addSubview:playerView];
    playerView.hidden = YES;
    self.playerView = playerView;
    
    // Activity indicator view
    PDDActivityView *activityView = [[PDDActivityView alloc] init];
    [activityView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [activityView setLabelText:@"Loading video..."];
    [view addSubview:activityView];
    self.activityView = activityView;
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[activityView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(activityView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[activityView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(activityView)]];

    
    self.view = view;
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Talk Video";
    
    NSDictionary *playerVars = @{
                                 @"showinfo" : @0,
                                 @"modestbranding" : @1,
                                 @"rel" : @0,
                                 };
    self.playerView.delegate = self;
    [self.playerView loadWithVideoId:self.video playerVars:playerVars];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Check if the view has appeared due to initial presentation
    // or due to being dismissed from the video playback.
    if (self.initialVideoPresentation) {
        [self _startVideoPlay];
    } else {
        [self _endVideoPlay];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - YTPlayerView delegate methods
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    self.isPlayerReady = YES;
    if (!self.initialVideoPresentation) {
        [self _startVideoPlay];
    }
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    if (state == kYTPlayerStateEnded) {
        [self _endVideoPlay];
    }
    if (state == kYTPlayerStatePlaying) {
        self.playerView.hidden = NO;
        [self.activityView stopActivity];
    }
}

#pragma mark - Private methods
- (void) _startVideoPlay {
    if (self.isPlayerReady) {
        [self.activityView startActivity];
        [self.playerView playVideo];
    }
}

- (void) _endVideoPlay {
    if (self.isPlayerReady) {
        if ([self.playerView playerState] == kYTPlayerStateEnded) {
            [self.playerView seekToSeconds:0.0f allowSeekAhead:NO];
            [self.playerView stopVideo];
        } else {
            [self.playerView pauseVideo];
        }
        self.playerView.hidden = YES;
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
