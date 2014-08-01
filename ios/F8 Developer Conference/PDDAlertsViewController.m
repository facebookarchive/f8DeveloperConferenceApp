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

#import "PDDAlertsViewController.h"
#import "PDDAlertsView.h"
#import "PDDAlertCell.h"
#import "PDDMessage.h"
#import "PDDEmptyView.h"
#import "PDDWebViewController.h"

#import "PDDUtils.h"
#import "UIColor+PDD.h"

@interface PDDAlertsViewController ()
@property (weak, nonatomic) PDDAlertsView *alertsView;
@property (strong, nonatomic) NSArray *alerts;
@property (weak, nonatomic) PDDEmptyView *emptyView;
@property (weak, nonatomic) UIRefreshControl *alertsRefreshControl;
@end

@implementation PDDAlertsViewController

#pragma mark - Initialization methods
- (id)init {
    if (self = [super init]) {
        self.title = @"Alerts";
        self.tabBarItem.image = [UIImage imageNamed:@"alerts"];
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)loadView {
    UIView *view = [[UIView alloc] init];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    PDDAlertsView * alertsView = [[PDDAlertsView alloc] init];
    alertsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    alertsView.dataSource = self;
    alertsView.delegate = self;
    [view addSubview:alertsView];
    self.alertsView = alertsView;
    // Hide extra table cell separators
    self.alertsView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    PDDEmptyView *emptyView = [[PDDEmptyView alloc]
                               initWithData:@{
                                              @"title": @"",
                                              @"content": @"Keep an eye on this space for event updates and session surveys"}];
    
    [emptyView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:emptyView];
    emptyView.hidden = YES;
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[emptyView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(emptyView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[emptyView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(emptyView)]];
    
    self.emptyView = emptyView;
    
    self.view = view;

}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor pddMainBackgroundColor];

    // Add refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(_refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.alertsView addSubview:refreshControl];
    self.alertsRefreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Populate data
    [self populateDataWithCompletionHandler:nil];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_alerts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kReuseIdentifier = @"alerts cell";
    PDDAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if (cell == nil) {
        cell = [[PDDAlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseIdentifier];
    }
    [cell setAlert:self.alerts[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PDDAlertCell *cell = (PDDAlertCell*) [tableView cellForRowAtIndexPath:indexPath];
    if (cell.alert.isSurvey && cell.alert.url && !cell.alert.isRead) {
        PDDWebViewController *webViewController = [[PDDWebViewController alloc] initWithURL:cell.alert.url title:cell.alert.title];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

#pragma mark - Public methods
- (void)populateDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    BOOL viewVisible = self.isViewLoaded && self.view.window;
    [[PDDUtils sharedInstance] findAlertsInBackgroundWithBlock:^(NSArray *alerts, NSError *error) {
        if (error) {
            if (completionHandler) {
                completionHandler(UIBackgroundFetchResultFailed);
            }
            if (viewVisible && ([error code] == kPFErrorConnectionFailed)) {
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"Your internet connection appears to be offline. Please connect and retry."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        } else {
            if ([alerts count] > 0) {
                self.alerts = alerts;
                NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(PDDMessage *alert, NSDictionary *bindings) {
                    return !(alert.isRead);
                }];
                NSArray *unreadAlerts = [self.alerts filteredArrayUsingPredicate:filterPredicate];
                if ([unreadAlerts count] > 0) {
                    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)[unreadAlerts count]];
                } else {
                    self.navigationController.tabBarItem.badgeValue = nil;
                }
                self.emptyView.hidden = YES;
                if (viewVisible) {
                    [self.alertsView reloadData];
                }
                if (completionHandler) {
                    completionHandler(UIBackgroundFetchResultNewData);
                    [UIApplication sharedApplication].applicationIconBadgeNumber = [unreadAlerts count];
                }
            } else {
                self.emptyView.hidden = NO;
                if (completionHandler) {
                    completionHandler(UIBackgroundFetchResultNoData);
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                }
            }
        }
        // Turn off refresh
        if (viewVisible && [self.alertsRefreshControl isRefreshing]) {
            [self.alertsRefreshControl endRefreshing];
        }
    }];
}

#pragma mark - Private methods
- (void)_refreshTableView:(id)sender {
    [self populateDataWithCompletionHandler:nil];
}

@end
