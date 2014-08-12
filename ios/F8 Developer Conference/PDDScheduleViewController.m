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

#import "PDDScheduleViewController.h"
#import "PDDTalkCell.h"
#import "PDDScheduleTrackView.h"
#import "PDDTrackListView.h"
#import "PDDTrackView.h"
#import "PDDScheduleTrackViewController.h"
#import "PDDWelcomeViewController.h"
#import "PDDTalk.h"
#import "PDDSlot.h"
#import "PDDRoom.h"
#import "PDDUtils.h"
#import "PDDConstants.h"

#import "UIColor+PDD.h"

#import <Parse/Parse.h>

typedef void (^PDDResultBlock)(BOOL result);

@interface PDDScheduleViewController()
<PDDTrackViewDelegate,
UIPageViewControllerDataSource,
UIPageViewControllerDelegate,
PDDScheduleTrackViewControllerDelegate>
@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *rawTalks;
@property (strong, nonatomic) NSDictionary *dataBySection;
@property (strong, nonatomic) NSArray *sortedSections;
@property (nonatomic) PDDTalkSectionType currentSectionSort;
@property (strong, nonatomic) NSMutableArray *scheduleViews;
@property (strong, nonatomic) PDDTrackListView *trackListView;
@property (strong, nonatomic) NSArray *scheduleTracks;
@property (assign, nonatomic) NSInteger selectedScheduleIndex;
@property (strong, nonatomic) UIPageViewController *schedulePageViewController;
@property (assign, nonatomic) CGPoint trackListViewOffset;
@property (assign, nonatomic) BOOL showLoadAnimation;
@end

@implementation PDDScheduleViewController

#pragma mark - Initialization methods
- (id)init {
    if (self = [super init]) {
        self.title = @"Schedule";
        self.tabBarItem.title = @"Schedule";
        self.tabBarItem.image = [UIImage imageNamed:@"schedule"];
        self.currentSectionSort = kPDDTalkSectionByTime;
        _scheduleViews = [@[] mutableCopy];
        _selectedScheduleIndex = 0;
        _trackListViewOffset = CGPointZero;
        _showLoadAnimation = NO;
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.backgroundColor = [UIColor pddNavyColor];
    self.view = view;

    CGFloat frameWidth = CGRectGetWidth([[UIScreen mainScreen] applicationFrame]);
    
    // Load header scroll view
    self.showLoadAnimation = YES;
    CGFloat yOffset = 0;
    CGFloat trackViewWidth = [PDDTrackView maxWidth] * kNumberOfTracksPerView;
    CGFloat trackViewHeight = [PDDTrackView maxHeight] + 10; // add padding
    PDDTrackListView *tracksView = [[PDDTrackListView alloc] initWithFrame:CGRectMake((frameWidth - trackViewWidth)/2, yOffset, trackViewWidth, trackViewHeight)];
    self.trackListView = tracksView;
    [self _setUpInitTrackListDisplay];
    
    self.schedulePageViewController =
    [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                  options:@{UIPageViewControllerOptionInterPageSpacingKey: @0.0f}];
    UIViewController *schedulePageZero = [self _scheduleViewControllerForPageIndex:0];
    self.schedulePageViewController.dataSource = self;
    self.schedulePageViewController.delegate = self;
    
    [self.schedulePageViewController setViewControllers:@[schedulePageZero]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:NULL];

    // Load full schedule scroll view
    CGFloat frameHeight = CGRectGetHeight([[UIScreen mainScreen] applicationFrame]);
    CGRect scheduleViewRect = CGRectMake(0,
                                         tracksView.frame.origin.y+tracksView.frame.size.height,
                                         frameWidth,
                                         frameHeight);

    [self.view addSubview:tracksView];

    [self addChildViewController:self.schedulePageViewController];
    self.schedulePageViewController.view.frame = scheduleViewRect;
    [self.view addSubview:self.schedulePageViewController.view];
    [self.schedulePageViewController didMoveToParentViewController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor pddNavyColor];
    
    [self _populateDataWithBlock:^(BOOL result) {
        if (result) {
            [self _setupContentDisplay];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Restore previous content offset for the track list scroll view
    if (nil != self.trackListView && !self.showLoadAnimation) {
        [self.trackListView setContentOffset:self.trackListViewOffset animated:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (nil != self.trackListView && self.showLoadAnimation) {
        [self _animateTrackListDisplay];
        self.showLoadAnimation = NO;
    }
}

#pragma mark - UIPageViewController datasource and delegate methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = 0;
    if ([viewController isKindOfClass:[PDDScheduleTrackViewController class]]) {
        PDDScheduleTrackViewController *vc = (PDDScheduleTrackViewController*) viewController;
        index = vc.pageIndex;
    } else if ([viewController isKindOfClass:[PDDWelcomeViewController class]]) {
        PDDWelcomeViewController *vc = (PDDWelcomeViewController*) viewController;
        index = vc.pageIndex;
    }
    return [self _scheduleViewControllerForPageIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = 0;
    if ([viewController isKindOfClass:[PDDScheduleTrackViewController class]]) {
        PDDScheduleTrackViewController *vc = (PDDScheduleTrackViewController*) viewController;
        index = vc.pageIndex;
    } else if ([viewController isKindOfClass:[PDDWelcomeViewController class]]) {
        PDDWelcomeViewController *vc = (PDDWelcomeViewController*) viewController;
        index = vc.pageIndex;
    }
    return [self _scheduleViewControllerForPageIndex:(index + 1)];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    UIViewController *viewController = pendingViewControllers[0];
    UIColor *colorToChangeTo;
    if ([viewController isKindOfClass:[PDDScheduleTrackViewController class]]) {
        PDDScheduleTrackViewController *vc = (PDDScheduleTrackViewController*) viewController;
        colorToChangeTo = [vc getHeaderViewBackgroundColor];
    } else if ([viewController isKindOfClass:[PDDWelcomeViewController class]]) {
        PDDWelcomeViewController *vc = (PDDWelcomeViewController*) viewController;
        colorToChangeTo = [vc getHeaderViewBackgroundColor];
    }
    [self _changeColorForTrack:colorToChangeTo];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    // Check if user completed transition
    UIViewController *viewController;
    if (completed) {
        viewController = pageViewController.viewControllers[0];
    } else {
        viewController = previousViewControllers[0];
    }
    NSInteger index = 0;
    UIColor *colorToChangeTo;
    if ([viewController isKindOfClass:[PDDScheduleTrackViewController class]]) {
        PDDScheduleTrackViewController *vc = (PDDScheduleTrackViewController*) viewController;
        index = vc.pageIndex;
        colorToChangeTo = [vc getHeaderViewBackgroundColor];
    } else if ([viewController isKindOfClass:[PDDWelcomeViewController class]]) {
        PDDWelcomeViewController *vc = (PDDWelcomeViewController*) viewController;
        index = vc.pageIndex;
        colorToChangeTo = [vc getHeaderViewBackgroundColor];
    }
    [self _changeColorForTrack:colorToChangeTo];
    if (index != self.selectedScheduleIndex) {
        [self _changeTrackSelected:index];
    }
    self.selectedScheduleIndex = index;
}

#pragma mark - PDDTrackViewDelegate methods
-(void)trackSelectionDidChange:(PDDTrackView *)selection {
    CGFloat trackViewWidth = [PDDTrackView maxWidth];
    CGFloat selectionOriginX = selection.frame.origin.x;
    NSInteger pageIndex = (NSInteger)floor(selectionOriginX / trackViewWidth) - 1;
    
    // Go to the selected track index
    [self goToTrack:pageIndex];
}

#pragma mark - PDDScheduleTrackViewControllerDelegate methods
-(void)refreshControlDidBegin:(PDDScheduleTrackViewController *)scheduleTrackViewController {
    [self _populateDataWithBlock:^(BOOL result) {
        if (result) {
            id sectionKey = self.sortedSections[scheduleTrackViewController.pageIndex - 1];
            [scheduleTrackViewController refreshTableView:self.dataBySection[sectionKey]];
        } else {
            // Pass in nil, no refresh
            [scheduleTrackViewController refreshTableView:nil];
        }
    }];
}

#pragma mark - Public methods
- (void)goToTrack:(NSInteger)pageIndex {
    // Check if making any changes
    if (pageIndex == self.selectedScheduleIndex) {
        return;
    }
    // Make the change
    [self _changeTrackSelected:pageIndex];
    [self _changeColorForTrackIndex:pageIndex];
    UIPageViewControllerNavigationDirection pageTransitionDirection;
    if (pageIndex > self.selectedScheduleIndex) {
        pageTransitionDirection = UIPageViewControllerNavigationDirectionForward;
    } else {
        pageTransitionDirection = UIPageViewControllerNavigationDirectionReverse;
    }
    self.selectedScheduleIndex = pageIndex;
    
    UIViewController *viewController = [self _scheduleViewControllerForPageIndex:pageIndex];
    __weak UIPageViewController *pvcw = self.schedulePageViewController;
    [self.schedulePageViewController setViewControllers:@[viewController]
                                              direction:pageTransitionDirection
                                               animated:YES completion:^(BOOL finished) {
                                                   UIPageViewController* pvcs = pvcw;
                                                   if (!pvcs) return;
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [pvcs setViewControllers:@[viewController]
                                                                      direction:pageTransitionDirection
                                                                       animated:NO completion:nil];
                                                   });
                                               }];
}

#pragma mark - Private methods
- (void)_populateDataWithBlock:(PDDResultBlock)resultBlock {
    [[PDDUtils sharedInstance] findAllTalksInBackgroundWithBlock:^(NSArray *talks, NSError *error) {
        if (!error) {
            self.rawTalks = talks;
            [self _reorderTableViewSectionsByTrack];
            if (resultBlock) {
                if ([self.rawTalks count] > 0) {
                    resultBlock(YES);
                } else {
                    resultBlock(NO);
                }
            }
            return;
        }
        BOOL viewVisible = self.isViewLoaded && self.view.window;
        if (viewVisible) {
            [[[UIAlertView alloc] initWithTitle:@""
                                        message:@"Your internet connection appears to be offline. Please connect and retry."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        if (resultBlock) {
            resultBlock(NO);
        }
    }];
}

- (void)_reorderTableViewSections {
    if ([self _isSortByTime]) {
        [self _reorderTableViewSectionsByTime];
    } else {
        [self _reorderTableViewSectionsByTrack];
    }
    [self.tableView reloadData];
}

- (void)_reorderTableViewSectionsByTime {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [self.rawTalks enumerateObjectsUsingBlock:^(PDDTalk *talk, NSUInteger idx, BOOL *stop) {
        if (talk.alwaysFavorite) {
            // Skip always-favorited talks in the Time Slot view
            return;
        }
        id groupKey = talk.slot.startTime;
        [self _setObject:talk inArray:groupKey inDictionary:dictionary];
    }];
    
    NSArray *sortedKeys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
    // a little extra conversion necessary
    NSMutableArray *dateStrings = [NSMutableArray arrayWithCapacity:[sortedKeys count]];
    [sortedKeys enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
        NSString *string = [PDDTalk stringTime:date];
        [dateStrings addObject:string];
        [dictionary setObject:[dictionary objectForKey:date] forKey:string];
        [dictionary removeObjectForKey:date];
    }];
    self.dataBySection = dictionary;
    self.sortedSections = dateStrings;
}

- (void)_reorderTableViewSectionsByTrack {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSMutableArray *sortedKeys = [@[] mutableCopy];
    [self.rawTalks enumerateObjectsUsingBlock:^(PDDTalk *talk, NSUInteger idx, BOOL *stop) {
        id groupKey;
        if (talk.alwaysFavorite) {
            groupKey = talk.title;
        } else {
            groupKey = talk.room.name;
        }
        [self _setObject:talk inArray:groupKey inDictionary:dictionary];
        if (![sortedKeys containsObject:groupKey]) {
            [sortedKeys addObject:groupKey];
        }
    }];
    self.dataBySection = dictionary;
    self.sortedSections = sortedKeys;
}

- (void)_setObject:(id)object inArray:(id)key inDictionary:(NSMutableDictionary *)dict {
    NSArray *sectionTalks = [dict objectForKey:key];
    if (sectionTalks) {
        [dict setObject:[sectionTalks arrayByAddingObject:object] forKey:key];
    } else {
        [dict setObject:@[ object ] forKey:key];
    }
}

- (BOOL)_isSortByTime {
    return self.currentSectionSort == kPDDTalkSectionByTime;
}

-(void)_setupContentDisplay {
    NSMutableArray *tracksForSchedule = [@[] mutableCopy];
    
    // Cleanup for back to back query results
    for (NSInteger i = 1; i < [self.scheduleTracks count]; i++) {
        UIView *childView = (UIView*) self.scheduleTracks[i];
        [childView removeFromSuperview];
    }
    if ([self.scheduleTracks count] > 0) {
        tracksForSchedule[0] = self.scheduleTracks[0];
    }
    
    CGFloat trackViewWidth = [PDDTrackView maxWidth];
    CGFloat trackViewHeight = [PDDTrackView maxHeight];
    for (NSInteger i=1; i < [self.sortedSections count]+1; i++) {
        // Account for filler track
        CGFloat trackViewFrameOffsetX = (i+1)*trackViewWidth;
        CGRect trackViewFrame = CGRectMake(trackViewFrameOffsetX, -40, trackViewWidth, trackViewHeight);
        PDDTrackView *trackView = [[PDDTrackView alloc] initWithFrame:trackViewFrame];
        id sectionKey = self.sortedSections[i-1];
        PDDTalk *firstTalk = self.dataBySection[sectionKey][0];
        [trackView setTalk:firstTalk];
        trackView.delegate = self;
        tracksForSchedule[i] = trackView;
        if (i == [self.sortedSections count]) {
            [trackView trimTimelineImageTrailing];
        }
        [self.trackListView addSubview:trackView];
    }
    [self.trackListView addSubview:[self _spacerTrackView]];
    self.scheduleTracks = tracksForSchedule;
    NSInteger addAnotherView = (([self.sortedSections count] + 2) % kNumberOfTracksPerView) > 0 ? 1 : 0;
    NSInteger numberOfTrackViews = (([self.sortedSections count] + 2) / kNumberOfTracksPerView) + addAnotherView;
    self.trackListView.contentSize = CGSizeMake(self.trackListView.frame.size.width * numberOfTrackViews, self.trackListView.frame.size.height+self.trackListViewOffset.y);
}

-(void)_setUpInitTrackListDisplay {
    [self.trackListView addSubview:[self _spacerTrackView]];
    CGFloat trackViewWidth = [PDDTrackView maxWidth];
    CGFloat trackViewHeight = [PDDTrackView maxHeight];
    CGRect trackViewFrame = CGRectMake(trackViewWidth, -40, trackViewWidth, trackViewHeight);
    PDDTrackView *trackView = [[PDDTrackView alloc] initWithFrame:trackViewFrame];
    [trackView setInitTrack];
    [trackView trimTimelineImageLeading];
    trackView.delegate = self;
    trackView.hidden = YES; // Hide initially for load animation
    [self.trackListView addSubview:trackView];
    self.scheduleTracks = @[trackView];
    self.trackListView.contentSize = CGSizeMake(self.trackListView.frame.size.width, self.trackListView.frame.size.height+self.trackListViewOffset.y);
    CGPoint offset = CGPointMake(0, self.trackListView.contentOffset.y);
    self.trackListViewOffset = offset;
    [self.trackListView setContentOffset:offset animated:NO];
}

-(void)_animateTrackListDisplay {
    CGFloat trackViewWidth = [PDDTrackView maxWidth];
    CGPoint firstTrackOffset = CGPointMake(0, self.trackListView.contentOffset.y);
    CGPoint lastTrackOffset = CGPointMake(self.trackListView.contentSize.width-(2*trackViewWidth), self.trackListView.contentOffset.y);
    self.trackListViewOffset = firstTrackOffset;
    // Animate initial load of the track list view.
    PDDTrackView *firstTrackView = self.scheduleTracks[0];
    firstTrackView.hidden = NO;
    [self.trackListView setContentOffset:lastTrackOffset animated:NO];
    [self.trackListView setContentOffset:firstTrackOffset animated:YES];
}

- (UIView *)_spacerTrackView {
    CGFloat trackViewWidth = [PDDTrackView maxWidth];
    CGFloat trackViewHeight = [PDDTrackView maxHeight];
    CGRect trackViewFrame = CGRectMake(0, -40, trackViewWidth, trackViewHeight);
    UIView *view = [[UIView alloc] initWithFrame:trackViewFrame];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIViewController *) _scheduleViewControllerForPageIndex:(NSInteger)pageIndex {
    if (pageIndex == 0) {
        PDDWelcomeViewController *welcomeViewController = [[PDDWelcomeViewController alloc] initWithPageIndex:pageIndex];
        return welcomeViewController;
    } else {
        NSInteger trackIndex = pageIndex - 1;
        if (trackIndex >= 0 && trackIndex < [self.sortedSections count]) {
            id sectionKey = self.sortedSections[trackIndex];
            PDDScheduleTrackViewController *scheduleViewController = [[PDDScheduleTrackViewController alloc] initWithTalks:self.dataBySection[sectionKey] atPageIndex:pageIndex];
            scheduleViewController.delegate = self;
            return scheduleViewController;
        }
    }
    
    return nil;
}

- (void) _changeTrackSelected:(NSInteger)page {
    for (NSInteger i = 0; i < [self.scheduleTracks count]; i++) {
        if (i == page) {
            [self.scheduleTracks[i] selectTrack:YES];
        } else {
            [self.scheduleTracks[i] selectTrack:NO];
        }
    }
    // Move track list scroll to appropriate spot
    NSInteger trackListPage = page / kNumberOfTracksPerView;
    NSInteger trackIndexInPage = page % kNumberOfTracksPerView;
    CGPoint offset = CGPointZero;
    CGRect trackViewFrame = self.trackListView.frame;
    
    CGFloat trackViewWidth = [PDDTrackView maxWidth];
    offset.x = (trackViewFrame.size.width * trackListPage) + (trackViewWidth * trackIndexInPage);
    offset.y = self.trackListView.contentOffset.y;
    self.trackListViewOffset = offset;
    // To avoid jittery transition in header scroll view,
    // make content offset change asynchronously.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.trackListView setContentOffset:offset animated:YES];
    });
}

- (void) _changeColorForTrackIndex:(NSInteger)page {
    UIColor *trackColor = [UIColor pddNavyColor];
    if (page > 0) {
        PDDTalk *firstTalk = [self.scheduleTracks[page] talk];
        if (firstTalk.room.displayColor) {
            trackColor = [UIColor colorWithRGB:firstTalk.room.displayColor];
        }
    }
    [self _changeColorForTrack:trackColor];
}

- (void) _changeColorForTrack:(UIColor *)trackColor {
    self.view.backgroundColor = trackColor;
    self.navigationController.navigationBar.barTintColor = trackColor;
    UIViewController *viewController = self.schedulePageViewController.viewControllers[0];
    if ([viewController isKindOfClass:[PDDScheduleTrackViewController class]]) {
        PDDScheduleTrackViewController *vc = (PDDScheduleTrackViewController*) viewController;
        [vc setHeaderViewBackgroundColor:trackColor];
    } else if ([viewController isKindOfClass:[PDDWelcomeViewController class]]) {
        PDDWelcomeViewController *vc = (PDDWelcomeViewController*) viewController;
        [vc setHeaderViewBackgroundColor:trackColor];
    }
}

@end
