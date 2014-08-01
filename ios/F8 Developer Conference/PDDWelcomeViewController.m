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

#import <Parse/Parse.h>

#import "PDDWelcomeViewController.h"
#import "PDDWelcomeView.h"
#import "PDDTalkHeaderView.h"
#import "PDDWelcomeCell.h"
#import "PDDGeneralInfo.h"
#import "PDDUtils.h"
#import "PDDAttributionView.h"
#import "PDDAppDelegate.h"

#import "UIColor+PDD.h"

@interface PDDWelcomeViewController ()
@property (strong, nonatomic) NSString *welcomeDescription;
@property (strong, nonatomic) NSArray *welcomeDetail;
@property (weak, nonatomic) PDDWelcomeView *welcomeView;
@property (weak, nonatomic) PDDTalkHeaderView *welcomeHeaderView;
@property (strong, nonatomic) UIColor *defaultHeaderBackgroundColor;
@property (weak, nonatomic) UIRefreshControl *welcomeRefreshControl;
@end

@implementation PDDWelcomeViewController

#pragma mark - Initialization methods
- (id)initWithPageIndex:(NSInteger)pageIndex {
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _pageIndex = pageIndex;
        _welcomeDescription = @"";
        _welcomeDetail = @[];
        _defaultHeaderBackgroundColor = [UIColor pddNavyColor];
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.welcomeView reloadData];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.welcomeHeaderView setSummaryViewBackgroundColor:self.defaultHeaderBackgroundColor];
}

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    
    // Attribution footer
    PDDAttributionView *footerImageView = [[PDDAttributionView alloc] init];
    [footerImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:footerImageView];
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[footerImageView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(footerImageView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[footerImageView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(footerImageView)]];
    
    // Main content
    PDDWelcomeView *welcomeView = [[PDDWelcomeView alloc] init];
    welcomeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    welcomeView.delegate = self;
    welcomeView.dataSource = self;
    [view addSubview:welcomeView];
    self.welcomeView = welcomeView;
    // Header
    PDDTalkHeaderView *headerView = [[PDDTalkHeaderView alloc]
                                     initWithData:@{@"title": @"Welcome",
                                                    @"time": @" ",
                                                    @"description": @" "}];
    self.welcomeView.tableHeaderView = headerView;
    self.welcomeHeaderView = headerView;
    
    // Hide extra table cell separators
    self.welcomeView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.welcomeView.tableFooterView.backgroundColor = [UIColor clearColor];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(_refreshTableView:) forControlEvents:UIControlEventValueChanged];
    [self.welcomeView addSubview:refreshControl];
    self.welcomeRefreshControl = refreshControl;
    
    // Populate initial data
    [self _populateData];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.welcomeDetail count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kReuseIdentifier = @"welcome cell";
    PDDWelcomeCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if (cell == nil) {
        cell = [[PDDWelcomeCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kReuseIdentifier];
    }
    [cell setInfo:self.welcomeDetail[indexPath.row]];
    
    return cell;
}

#pragma mark - Public methods
- (void) setHeaderViewBackgroundColor:(UIColor *) color {
    [self.welcomeHeaderView setSummaryViewBackgroundColor:color];
}

- (UIColor *) getHeaderViewBackgroundColor {
    return self.defaultHeaderBackgroundColor;
}

#pragma mark - Private methods
- (void)_populateData {
    [[PDDUtils sharedInstance] findInfoInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PDDGeneralInfo *generalInfo = (PDDGeneralInfo *)object;
            self.welcomeDescription = generalInfo[@"description"];
            self.welcomeDetail = generalInfo.detail;
            [self.welcomeView reloadData];
            NSString *title = @"Welcome";
            if ([PFUser currentUser][@"firstName"]) {
                title = [NSString stringWithFormat:@"Welcome, %@", [PFUser currentUser][@"firstName"]];
            }
            self.welcomeHeaderView.data = @{@"title": title,
                                            @"time": @" ",
                                            @"description": self.welcomeDescription};
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
        if ([self.welcomeRefreshControl isRefreshing]) {
            [self.welcomeRefreshControl endRefreshing];
        }
    }];
}

- (void)_refreshTableView:(id)sender {
    [self _populateData];
}
@end
