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

#import "PDDBaseListViewController.h"
#import "PDDTalkViewController.h"
#import "PDDTalkListViewController.h"
#import "PDDConstants.h"

#import "PDDTalkViewAnimationController.h"

#import "PDDTalkCell.h"
#import "UIColor+PDD.h"
#import "PDDUtils.h"

@interface PDDBaseListViewController () <UIViewControllerTransitioningDelegate, PDDTalkListViewControllerDelegate>
@property (strong, nonatomic) PDDTalkViewAnimationController *animationController;
@end

@implementation PDDBaseListViewController

#pragma mark - Initialization methods
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoriteAdded:)
                                                 name:PDDTalkFavoriteTalkAddedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoriteRemoved:)
                                                 name:PDDTalkFavoriteTalkRemovedNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDDTalkFavoriteTalkAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDDTalkFavoriteTalkRemovedNotification object:nil];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PDDTalk *selectedTalk = [self talkForIndexPath:indexPath];
    if (!selectedTalk.isBreak) {
        NSArray *talkList = [self _talkListForPages];
        NSInteger startingTalkIndex = [self _startingTalkIndexForPages:indexPath];
        if ([talkList count] > 0) {
            // For handling animations to talk view
            if (nil == self.animationController) {
                self.animationController = [[PDDTalkViewAnimationController alloc] init];
            }
            PDDTalkListViewController *talkListViewController =
            [[PDDTalkListViewController alloc] initWithTalks:talkList
                                                 atPageIndex:startingTalkIndex];
            talkListViewController.delegate = self;
            talkListViewController.transitioningDelegate = self;
            [self presentViewController:talkListViewController animated:YES completion:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    return sectionTitle ? 40 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (!title) {
        return nil;
    }
    static NSString *reuseHeaderIdentifier = @"section header";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseHeaderIdentifier];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reuseHeaderIdentifier];
        headerView.textLabel.textColor = [UIColor pddTextColor];
        headerView.backgroundView = [[UIView alloc] init];
        headerView.backgroundView.backgroundColor = [UIColor pddContentBackgroundColor];
    }
    headerView.textLabel.text = [NSString stringWithFormat:@"    %@", title];

    return headerView;
}

#pragma mark - UIViewControllerTransitioningDelegate methods
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.animationController;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    // Handling interactive dismisal of the talk view controller
    PDDTalkViewAnimationController *controller = (PDDTalkViewAnimationController *)animator;
    if (controller.isInteractive) {
        return controller;
    } else {
        return nil;
    }
}

#pragma mark - PDDTalkListViewControllerDelegate methods
-(void)talkListViewController:(PDDTalkListViewController *)talkListViewController didTransition:(UIViewController *)viewController {
    // Update the view to be used for transition interactive animations
    PDDTalkViewController *talkViewController = (PDDTalkViewController *) viewController;
    self.animationController.viewControllerToDismiss = talkViewController;
}

#pragma mark - Public methods
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
    // Optimistically toggle the UI, for animation
    [talkCell toggleFavorite:newFavorite];
}

- (PDDTalk *)talkForIndexPath:(NSIndexPath *)indexPath {
    [NSException raise:NSGenericException format:@"Not implemented by subclass"];
    return nil;
}

- (void)favoriteAdded:(NSNotification *)notification {
    [NSException raise:NSGenericException format:@"Not implemented by subclass"];
}

- (void)favoriteRemoved:(NSNotification *)notification {
    [NSException raise:NSGenericException format:@"Not implemented by subclass"];
}

#pragma mark - Private methods
- (NSArray *)_talkListForPages {
    [NSException raise:NSGenericException format:@"Not implemented by subclass"];
    return nil;
}

- (NSInteger)_startingTalkIndexForPages:(NSIndexPath *)indexPath {
    [NSException raise:NSGenericException format:@"Not implemented by subclass"];
    return -1;
}

@end
