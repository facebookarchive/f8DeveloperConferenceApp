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

#import "PDDMapListViewController.h"
#import "PDDMapViewController.h"

#import "UIColor+PDD.h"

@interface PDDMapListViewController () <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *mapPageViewController;
@property (weak, nonatomic) UIPageControl *mapPageControl;
@property (strong, nonatomic) NSArray *mapInfo;
@property (assign, nonatomic) NSInteger selectedMapIndex;
@end

@implementation PDDMapListViewController

#pragma mark - Initialization methods
- (id)init {
    if (self = [super init]) {
        self.title = @"Map";
        self.tabBarItem.image = [UIImage imageNamed:@"places"];
        self.tabBarItem.title = @"Map";
        _selectedMapIndex = 0;
        _mapInfo = @[
                     @{@"title": @"Morning",
                       @"image": [UIImage imageNamed:@"map-morning"]
                       },
                     @{@"title": @"Afternoon",
                       @"image": [UIImage imageNamed:@"map-afternoon"]
                       },
                     @{@"title": @"Evening",
                       @"image": [UIImage imageNamed:@"map-evening"]
                       }
                     ];
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.backgroundColor = [UIColor pddContentBackgroundColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.mapPageViewController =
    [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                  options:@{UIPageViewControllerOptionInterPageSpacingKey: @20.0f}];
    [self _updatePageIndexInfo:0];
    UIViewController *pageZero = [self _mapViewControllerForPageIndex:0];
    self.mapPageViewController.dataSource = self;
    [self.mapPageViewController setViewControllers:@[pageZero]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:NULL];

    
    [self addChildViewController:self.mapPageViewController];
    UIView *mapView = self.mapPageViewController.view;
    [mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [view addSubview:mapView];
    [self.mapPageViewController didMoveToParentViewController:self];
    
    UIPageControl *mapPageControl = [[UIPageControl alloc] init];
    [mapPageControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mapPageControl addTarget:self
                       action:@selector(_pageSelectionChanged:)
             forControlEvents:UIControlEventValueChanged];
    mapPageControl.numberOfPages = [self.mapInfo count];
    [view addSubview:mapPageControl];
    self.mapPageControl = mapPageControl;
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(mapView,mapPageControl)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(mapView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapPageControl]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(mapPageControl)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[mapPageControl(40)]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(mapPageControl)]];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor pddMainBackgroundColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewControllerDataSource methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    PDDMapViewController *mapViewController = (PDDMapViewController *)viewController;
    NSInteger index = mapViewController.pageIndex;
    [self _updatePageIndexInfo:index];
    return [self _mapViewControllerForPageIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    PDDMapViewController *mapViewController = (PDDMapViewController *)viewController;
    NSInteger index = mapViewController.pageIndex;
    [self _updatePageIndexInfo:index];
    return [self _mapViewControllerForPageIndex:(index + 1)];
}

#pragma mark - Private methods
- (UIViewController *)_mapViewControllerForPageIndex:(NSInteger)pageIndex {
    if (pageIndex >= 0 && pageIndex < [self.mapInfo count]) {
        PDDMapViewController *mapViewController = [[PDDMapViewController alloc] initWithData:self.mapInfo[pageIndex] atPageIndex:pageIndex];
        return mapViewController;
    }
    return nil;
}

- (void)_pageSelectionChanged:(id)sender {
    NSInteger pageIndex = self.mapPageControl.currentPage;
    UIPageViewControllerNavigationDirection pageTransitionDirection;
    if (pageIndex > self.selectedMapIndex) {
        pageTransitionDirection = UIPageViewControllerNavigationDirectionForward;
    } else {
        pageTransitionDirection = UIPageViewControllerNavigationDirectionReverse;
    }
    [self _updatePageIndexInfo:pageIndex];
    UIViewController *page = [self _mapViewControllerForPageIndex:pageIndex];
    __weak UIPageViewController* pvcw = self.mapPageViewController;
    [self.mapPageViewController setViewControllers:@[page]
                                              direction:pageTransitionDirection
                                               animated:YES completion:^(BOOL finished) {
                                                   UIPageViewController* pvcs = pvcw;
                                                   if (!pvcs) return;
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [pvcs setViewControllers:@[page]
                                                                      direction:pageTransitionDirection
                                                                       animated:NO completion:nil];
                                                   });
                                               }];
}

- (void)_updatePageIndexInfo:(NSInteger)index {
    self.selectedMapIndex = index;
    self.mapPageControl.currentPage = index;
    self.title = self.mapInfo[index][@"title"];
    self.tabBarItem.title = @"Map";
}

@end
