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

#import "PDDSettingsViewController.h"
#import "PDDAppDelegate.h"
#import "PDDAboutViewController.h"
#import "UIColor+PDD.h"
#import "UIFont+PDD.h"

@interface PDDSettingsViewController ()

@end

@implementation PDDSettingsViewController

#pragma mark - Initialization methods
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Settings";
        
        self.tableView.backgroundColor = [UIColor pddContentBackgroundColor];
        self.tableView.separatorColor = [UIColor pddSeparatorColor];
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide extra table cell separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kReuseIdentifier = @"settings cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReuseIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont pddH2];
        cell.textLabel.textColor = [UIColor pddTextColor];
    }
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"About";
            break;
        }
        case 1:
        {
            cell.textLabel.text = @"Terms and Privacy";
            break;
        }
        case 2:
        {
            cell.textLabel.text = @"Log Out";
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            PDDAboutViewController *aboutViewController = [[PDDAboutViewController alloc] init];
            [self.navigationController pushViewController:aboutViewController animated:YES];
            break;
        }
        case 1:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.facebook.com/policies?_rdr"]];
            break;
        }
        case 2:
        {
            PDDAppDelegate *delegate = (PDDAppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate logout];
            break;
        }
        default:
            break;
    }
}


@end
