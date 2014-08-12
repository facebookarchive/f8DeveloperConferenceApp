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

#import "PDDMyScheduleViewController.h"
#import "PDDMyScheduleView.h"
#import "PDDMyTalkCell.h"
#import "PDDConstants.h"
#import "PDDSettingsViewController.h"

#import "PDDTalk.h"
#import "PDDRoom.h"
#import "PDDSlot.h"

#import "PDDUtils.h"
#import "UIColor+PDD.h"

@interface PDDMyScheduleViewController ()
@property (weak, nonatomic) PDDMyScheduleView *scheduleView;
@property (strong, nonatomic) NSArray *favoritedTalks;
@property (strong, nonatomic) NSDictionary *dataBySection;
@property (strong, nonatomic) NSArray *sortedSections;
@property (weak, nonatomic) UIRefreshControl *myScheduleRefreshControl;
@property (strong, nonatomic) NSArray *nonBreakTalkData;
@property (strong, nonatomic) NSDictionary *nonBreakTalkDataMap;
@end

@implementation PDDMyScheduleViewController

#pragma mark - Initialization methods
- (id)init {
    if (self = [super init]) {
        self.title = @"My Schedule";
        self.tabBarItem.title = @"My Schedule";
        self.tabBarItem.image = [UIImage imageNamed:@"myschedule"];
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)loadView {
    UIView *view = [[UIView alloc] init];
    
    // Main content
    PDDMyScheduleView *myScheduleView = [[PDDMyScheduleView alloc] init];
    myScheduleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    myScheduleView.dataSource = self;
    myScheduleView.delegate = self;
    [view addSubview:myScheduleView];
    
    self.scheduleView = myScheduleView;
    // Hide extra table cell separators
    self.scheduleView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor pddMainBackgroundColor];
    
    // Add the settings button
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"gear"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(_goToSettings:)];
    self.navigationItem.rightBarButtonItem = settingsBarButtonItem;
    
    // Add refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(_refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.scheduleView addSubview:refreshControl];
    self.myScheduleRefreshControl = refreshControl;
    
    // Populate initial data
    [self _populateData];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.favoritedTalks count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"favorite cell";
    PDDMyTalkCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[PDDMyTalkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.sectionType = kPDDTalkSectionByTrack;
        [cell.favoriteButton addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    }

    cell.talk = [self talkForIndexPath:indexPath];
    return cell;
}

#pragma mark - PDDBaseListViewController methods
- (void)favorite:(id)sender {
    UIView *target = sender;
    PDDTalkCell *talkCell;
    while ([target superview]) {
        if ([[target superview] isKindOfClass:[PDDTalkCell class]]) {
            talkCell = (PDDTalkCell *)[target superview];
        }
        target = [target superview];
    }
    
    BOOL newFavorite = ![talkCell.talk isFavorite];
    [talkCell.talk toggleFavorite:newFavorite];
}

- (PDDTalk *)talkForIndexPath:(NSIndexPath *)indexPath {
    if ([self.favoritedTalks count] == 0) {
        return nil;
    }
    return [self.favoritedTalks objectAtIndex:indexPath.row];
}

- (void)favoriteAdded:(NSNotification *)notification {
    self.favoritedTalks = [PDDUtils sortedTalkArray:[self.favoritedTalks arrayByAddingObject:notification.object]];
    [self.scheduleView reloadData];
}

- (void)favoriteRemoved:(NSNotification *)notification {
    PDDTalk *removedTalk = notification.object;
    
    // To handle deletion animation
    [self.scheduleView beginUpdates];
    for (NSInteger i = 0; i < [self.favoritedTalks count]; i++) {
        PDDTalk *talkToCheck = self.favoritedTalks[i];
        if ([talkToCheck.objectId isEqualToString:removedTalk.objectId]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.scheduleView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
    }
    NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(PDDTalk *talk, NSDictionary *bindings) {
        return ![talk.objectId isEqualToString:removedTalk.objectId];
    }];
    self.favoritedTalks = [self.favoritedTalks filteredArrayUsingPredicate:filterPredicate];
    [self.scheduleView endUpdates];
}

- (NSArray *)_talkListForPages {
    return self.favoritedTalks;
}

- (NSInteger)_startingTalkIndexForPages:(NSIndexPath *)indexPath {
    return indexPath.row;
}

#pragma mark - Private methods
- (void)_populateData {
    [[PDDUtils sharedInstance] findFavoriteTalksInBackgroundWithBlock:^(NSArray *talks, NSError *error) {
        if (!error) {
            if ([talks count] > 0) {
                self.favoritedTalks = talks;
                [self.scheduleView reloadData];
            }
        } else if ([error code] == kPFErrorConnectionFailed) {
            BOOL viewVisible = self.isViewLoaded && self.view.window;
            if (viewVisible) {
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"Your internet connection appears to be offline. Please connect and retry."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        }
        if ([self.myScheduleRefreshControl isRefreshing]) {
            [self.myScheduleRefreshControl endRefreshing];
        }
    }];
}

- (void)_refreshTableView:(id)sender {
    [self _populateData];
}

- (void)_goToSettings:(id)sender {
    PDDSettingsViewController *settingsViewController = [[PDDSettingsViewController alloc] init];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

@end
