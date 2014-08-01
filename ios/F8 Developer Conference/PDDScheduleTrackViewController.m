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

#import "PDDScheduleTrackViewController.h"
#import "PDDScheduleTrackView.h"
#import "PDDTalkHeaderView.h"
#import "PDDTalkCell.h"
#import "PDDRoom.h"
#import "UIColor+PDD.h"
#import "PDDTalkHeaderView.h"
#import "PDDAttributionView.h"

@interface PDDScheduleTrackViewController ()
@property (strong, nonatomic) NSArray *talkData;
@property (strong, nonatomic) NSArray *nonBreakTalkData;
@property (strong, nonatomic) NSDictionary *nonBreakTalkDataMap;
@property (weak, nonatomic) PDDTalkHeaderView *scheduleTrackHeaderView;
@property (weak, nonatomic) PDDTalkHeaderView *scheduleTrackTableHeaderView;
@property (weak, nonatomic) PDDScheduleTrackView *scheduleTrackTableView;
@property (weak, nonatomic) PDDAttributionView *footerImageView;
@property (strong, nonatomic) UIColor *defaultHeaderBackgroundColor;
@property (weak, nonatomic) UIRefreshControl *scheduleRefreshControl;
@property (strong, nonatomic) UIPageViewController *talkPageViewController;
@end

@implementation PDDScheduleTrackViewController

#pragma mark - Initialization methods
-(id)initWithTalks:(NSArray *)talks atPageIndex:(NSInteger)pageIndex {
    self = [super init];
    if (self) {
        _talkData = talks;
        [self _mapNonBreakTalks:talks];
        _pageIndex = pageIndex;
        _defaultHeaderBackgroundColor = [UIColor pddNavyColor];
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void) loadView {
    UIView *view = [[UIView alloc] init];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Header view
    PDDTalkHeaderView *headerView = [[PDDTalkHeaderView alloc] init];
    [view addSubview:headerView];
    self.scheduleTrackHeaderView = headerView;

    // Table header view
    PDDTalkHeaderView *tableHeaderView = [[PDDTalkHeaderView alloc] init];
    self.scheduleTrackTableHeaderView = tableHeaderView;
    
    // Attribution footer
    PDDAttributionView *footerImageView = [[PDDAttributionView alloc] init];
    [footerImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:footerImageView];
    self.footerImageView = footerImageView;
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[footerImageView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(footerImageView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[footerImageView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(footerImageView)]];
    
    // The table view
    PDDScheduleTrackView *scheduleTrackTableView = [[PDDScheduleTrackView alloc] init];
    scheduleTrackTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scheduleTrackTableView.delegate = self;
    scheduleTrackTableView.dataSource = self;
    scheduleTrackTableView.tableHeaderView = tableHeaderView;
    [view addSubview:scheduleTrackTableView];
    self.scheduleTrackTableView = scheduleTrackTableView;
    
    // Hide extra table cell separators
    self.scheduleTrackTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.scheduleTrackTableView.tableFooterView.backgroundColor = [UIColor pddContentBackgroundColor];
    
    self.view = view;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Add refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(_initiateDataRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.scheduleTrackTableView addSubview:refreshControl];
    self.scheduleRefreshControl = refreshControl;
    
    // Populate initial data
    [self _populateData];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scheduleTrackHeaderView setSummaryViewBackgroundColor:self.defaultHeaderBackgroundColor];
    [self.scheduleTrackTableHeaderView setSummaryViewBackgroundColor:self.defaultHeaderBackgroundColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource and UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_talkData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kReuseIdentifier = @"schedule cell";
    PDDTalkCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if (cell == nil) {
        cell = [[PDDTalkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseIdentifier];
        [cell.favoriteButton addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.sectionType = kPDDTalkSectionByTrack;
    [cell setTalk:[self talkForIndexPath:indexPath]];
    
    return cell;
}

#pragma mark - PDDBaseListViewController methods
- (PDDTalk *)talkForIndexPath:(NSIndexPath *)indexPath {
    return self.talkData[indexPath.row];
}

- (void)favoriteAdded:(NSNotification *)notification {
    [self.scheduleTrackTableView reloadData];
}

- (void)favoriteRemoved:(NSNotification *)notification {
    // Could load just visible cells but sometimes
    // incorrect content is shown.
    [self.scheduleTrackTableView reloadData];
}

- (NSArray *)_talkListForPages {
    return self.nonBreakTalkData;
}

- (NSInteger)_startingTalkIndexForPages:(NSIndexPath *)indexPath {
    NSNumber *index = [NSNumber numberWithInteger:indexPath.row];
    return [self.nonBreakTalkDataMap[index] integerValue];
}

#pragma mark - Public methods
- (void) setHeaderViewBackgroundColor:(UIColor *) color {
    [self.scheduleTrackHeaderView setSummaryViewBackgroundColor:color];
    [self.scheduleTrackTableHeaderView setSummaryViewBackgroundColor:color];
}

- (UIColor *) getHeaderViewBackgroundColor {
    return self.defaultHeaderBackgroundColor;
}

- (void)refreshTableView:(NSArray *)talks {
    if (nil != talks) {
        self.talkData = talks;
        [self _populateData];
        [self.scheduleTrackTableView reloadData];
    }
    if ([self.scheduleRefreshControl isRefreshing]) {
        [self.scheduleRefreshControl endRefreshing];
    }
}

#pragma mark - Private methods
- (void)_reloadVisibleRows {
    [self.scheduleTrackTableView
     reloadRowsAtIndexPaths:[self.scheduleTrackTableView indexPathsForVisibleRows]
     withRowAnimation:UITableViewRowAnimationNone];
}

- (void)_populateData {
    PDDTalk *firstTalk = self.talkData[0];
    if (firstTalk.alwaysFavorite) {
        // Header view is the basic content
        NSString *description = firstTalk.abstract ? firstTalk.abstract : @"";
        self.scheduleTrackHeaderView.data = @{@"title": firstTalk.title,
                                              @"time": firstTalk.talkTime,
                                              @"description": description};
        self.view.backgroundColor = [UIColor pddContentBackgroundColor];
        
        self.defaultHeaderBackgroundColor = [UIColor pddNavyColor];
        [self.scheduleTrackHeaderView setSummaryViewBackgroundColor:self.defaultHeaderBackgroundColor];
        [self.scheduleTrackHeaderView hideSeparatorView];
        
        // Give simple content more room for the description which can get long.
        CGRect headerFrame = self.scheduleTrackHeaderView.frame;
        headerFrame.size.height += 150;
        self.scheduleTrackHeaderView.frame = headerFrame;
        
        [self.scheduleTrackTableView removeFromSuperview];
        [self.footerImageView removeFromSuperview];
    } else if (firstTalk.allDay) {
        // Header view is the basic content
        NSString *description = firstTalk.room[@"description"] ? firstTalk.room[@"description"] : @"";
        self.scheduleTrackHeaderView.data = @{@"title": firstTalk.room.name,
                                              @"time": @"ALL DAY",
                                              @"description": description};
        self.view.backgroundColor = [UIColor pddContentBackgroundColor];
        
        if (firstTalk.room.displayColor) {
            self.defaultHeaderBackgroundColor = [UIColor colorWithRGB:firstTalk.room.displayColor];
            [self.scheduleTrackHeaderView setSummaryViewBackgroundColor:self.defaultHeaderBackgroundColor];
        }
        [self.scheduleTrackHeaderView hideSeparatorView];
        
        // Give simple content more room for the description which can get long.
        CGRect headerFrame = self.scheduleTrackHeaderView.frame;
        headerFrame.size.height += 150;
        self.scheduleTrackHeaderView.frame = headerFrame;
        
        [self.scheduleTrackTableView removeFromSuperview];
        [self.footerImageView removeFromSuperview];
    } else {
        NSString *description = firstTalk.room[@"description"] ? firstTalk.room[@"description"] : @"";
        self.scheduleTrackTableHeaderView.data = @{@"title": firstTalk.room.name,
                                              @"time": firstTalk.talkTime,
                                              @"description": description};

        if (firstTalk.room.displayColor) {
            self.defaultHeaderBackgroundColor = [UIColor colorWithRGB:firstTalk.room.displayColor];
            [self.scheduleTrackTableHeaderView setSummaryViewBackgroundColor:self.defaultHeaderBackgroundColor];
        }
        
        // Hide extra table cell separators
        CGRect tableFooterFrame = self.scheduleTrackTableView.tableFooterView.frame;
        // Make table footer longer if needed, i.e. too few rows.
        if ([self.talkData count] < 2) {
            tableFooterFrame.size.height = 100;
        }
        self.scheduleTrackTableView.tableFooterView.frame = tableFooterFrame;
        [self.scheduleTrackHeaderView removeFromSuperview];
    }
}

- (void)_initiateDataRefresh:(id)sender {
    if ([self.delegate respondsToSelector:@selector(refreshControlDidBegin:)]) {
        [self.delegate refreshControlDidBegin:self];
    }
}

- (void) _mapNonBreakTalks:(NSArray*)talkData {
    NSMutableDictionary *nonBreakTalkDataMap = [@{} mutableCopy];
    NSMutableArray *nonBreakTalkData = [@[] mutableCopy];
    __block NSInteger filteredIndex = 0;
    [talkData enumerateObjectsUsingBlock:^(PDDTalk *talk, NSUInteger idx, BOOL *stop) {
        if (!talk.isBreak) {
            [nonBreakTalkData addObject:talk];
            NSNumber *key = [NSNumber numberWithInteger:idx];
            nonBreakTalkDataMap[key] = [NSNumber numberWithInteger:filteredIndex];
            filteredIndex++;
        }
    }];
    _nonBreakTalkData = nonBreakTalkData;
    _nonBreakTalkDataMap = nonBreakTalkDataMap;
}

@end
