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

#import "PDDTalkViewAnimationController.h"
#import "PDDTalkViewController.h"
#import "PDDTalkView.h"

@interface PDDTalkViewAnimationController() <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) PDDTalkView *viewForInteraction;
@end

@implementation PDDTalkViewAnimationController

#pragma mark - Initialization
-(instancetype)init {
    self = [super init];
    if (self) {
        // Initialize the pan gesture recognizer
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(_handlePan:)];
        _panGestureRecognizer.delegate = self;
        _panGestureRecognizer.minimumNumberOfTouches = 1;
        _panGestureRecognizer.maximumNumberOfTouches = 1;
    }
    return self;
}

#pragma mark - Animated Transitioning methods
- (NSTimeInterval)transitionDuration:
(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:
(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect finalFrame = [transitionContext
                         finalFrameForViewController:toViewController];
    CGRect initialFrame = [transitionContext
                           initialFrameForViewController:fromViewController];
    UIView *containerView = [transitionContext containerView];
    
    CGRect offscreenRect = initialFrame;
    offscreenRect.origin.y += CGRectGetHeight(initialFrame);
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    toViewController.view.frame = finalFrame;
    toViewController.view.alpha = 0.5;
    
    [containerView addSubview:toViewController.view];
    [containerView sendSubviewToBack:toViewController.view];
    
    // Animate the view offscreen
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
        toViewController.view.alpha = 1.0;
        fromViewController.view.frame = offscreenRect;
    } completion: ^(BOOL finished) {
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

-(void)animationEnded:(BOOL)transitionCompleted {
    self.interactive = NO;
}

#pragma mark - Interactive Transitioning methods
- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [super updateInteractiveTransition:percentComplete];
}

- (void)finishInteractiveTransition {
    [super finishInteractiveTransition];
}

- (void)cancelInteractiveTransition {
    [super cancelInteractiveTransition];
}

#pragma mark - Setter methods
-(void)setViewForInteraction:(PDDTalkView *)viewForInteraction {
    if (_viewForInteraction && [_viewForInteraction isEqual:viewForInteraction]) {
        return;
    }
    if (_viewForInteraction && [_viewForInteraction.gestureRecognizers containsObject:_panGestureRecognizer]) {
        [_viewForInteraction removeGestureRecognizer:_panGestureRecognizer];
    }
    _viewForInteraction = viewForInteraction;
    [_viewForInteraction addGestureRecognizer:_panGestureRecognizer];
}

-(void)setViewControllerToDismiss:(UIViewController *)viewControllerToDismiss {
    _viewControllerToDismiss = viewControllerToDismiss;
    PDDTalkViewController *talkViewController = (PDDTalkViewController *) viewControllerToDismiss;
    // Add gesture recognizer to the talk view
    self.viewForInteraction = talkViewController.talkView;
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Private methods
- (void)_handlePan:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
    CGFloat progress = translation.y / (gestureRecognizer.view.bounds.size.height * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Since we support side swipes and pans down, check which one
        // may be in play before dismissing the modal view controller
        if (fabsf(velocity.y) - fabsf(velocity.x) > 30.0f) {
            // Activate interactive mode and dismiss the view controller
            self.interactive = YES;
            [self.viewControllerToDismiss.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // Update the interactive transition's progress
        [self updateInteractiveTransition:progress];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        // Finish or cancel the interactive transition
        if ((velocity.y > 500.0) || (translation.y > 50.0)) {
            [self finishInteractiveTransition];
        }
        else {
            [self cancelInteractiveTransition];
        }
        // Deactivate interactive mode
        self.interactive = NO;
    }
}


@end
