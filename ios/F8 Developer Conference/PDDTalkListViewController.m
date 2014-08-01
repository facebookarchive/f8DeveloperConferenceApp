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

#import "PDDTalkListViewController.h"
#import "PDDTalkViewController.h"
#import "PDDTalk.h"

#import "UIColor+PDD.h"

@interface PDDTalkListViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (strong, nonatomic) NSArray *talkData;
@property (strong, nonatomic) UIPageViewController *talkPageViewController;
@property NSUInteger startingPageIndex;
@end

@implementation PDDTalkListViewController

#pragma mark - Initialization methods
-(id)initWithTalks:(NSArray *)talks atPageIndex:(NSInteger)pageIndex {
    self = [super init];
    if (self) {
        _talkData = talks;
        _startingPageIndex = pageIndex;
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.talkPageViewController =
    [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                  options:@{UIPageViewControllerOptionInterPageSpacingKey: @20.0f}];
    
    UIViewController *initialPage = [self talkViewControllerForPageIndex:self.startingPageIndex];
    self.talkPageViewController.dataSource = self;
    self.talkPageViewController.delegate = self;
    [self.talkPageViewController setViewControllers:@[initialPage]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:NULL];
    [self addChildViewController:self.talkPageViewController];
    [self _callTransitionDelegate:initialPage];
    UIView *talkView = self.talkPageViewController.view;
    [talkView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:talkView];
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[talkView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(talkView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[talkView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(talkView)]];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor pddMainBackgroundColor];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// Since we allow rotation in the video view controller,
// presented from the child talk view controller, allow
// an interface reset.
-(BOOL)shouldAutorotate {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewController delegate
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    // Check if user completed transition
    UIViewController *viewController;
    if (completed) {
        viewController = pageViewController.viewControllers[0];
    } else {
        viewController = previousViewControllers[0];
    }
    // Inform the delegate
    [self _callTransitionDelegate:viewController];
}

#pragma mark - UIPageViewController datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    PDDTalkViewController *talkViewController = (PDDTalkViewController *)viewController;
    NSInteger index = talkViewController.pageIndex;
    return [self talkViewControllerForPageIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    PDDTalkViewController *talkViewController = (PDDTalkViewController *)viewController;
    NSInteger index = talkViewController.pageIndex;
    return [self talkViewControllerForPageIndex:(index + 1)];
}

- (UIViewController *)talkViewControllerForPageIndex:(NSInteger)pageIndex {
    if (pageIndex >= 0 && pageIndex < [self.talkData count]) {
        PDDTalk *talk = self.talkData[pageIndex];
        PDDTalkViewController *talkViewController = [[PDDTalkViewController alloc] initWithTalk:talk atPageIndex:pageIndex];
        return talkViewController;
    }
    return nil;
}

#pragma mark - Private methods
- (void)_callTransitionDelegate:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(talkListViewController:didTransition:)]) {
        [self.delegate talkListViewController:self didTransition:viewController];
    }
}

@end
