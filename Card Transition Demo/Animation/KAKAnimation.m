//
//  KAKAnimation.m
//  Card Transition Demo
//
//  Created by Mingfei Huang on 11/4/18.
//  Copyright © 2018 Mingfei Huang. All rights reserved.
//

#import "KAKAnimation.h"

#import <YYKit/YYKit.h>

@interface KAKAnimation ()

// frame of `self.triggerView` in coordinate of container view
@property (assign, nonatomic) CGRect triggerViewFrame;

@property (strong, nonatomic) UIView *triggerViewParentView;

@end

@implementation KAKAnimation

+ (instancetype)instanceWithTriggerView:(UIView *)triggerView
               presentingViewController:(UIViewController<KAKAnimationPresentingViewController> *)presentingViewController
                presentedViewController:(UIViewController<KAKAnimationPresentedViewController> *)presentedViewController
{
    KAKAnimation *inst = self.new;
    if (!inst) {
        return nil;
    }
    inst->_triggerView = triggerView;
    inst->_presentingViewController = presentingViewController;
    inst->_presentedViewController = presentedViewController;
    return inst;
}

- (void)dismissInteractively:(BOOL)interactively
{
    _dismissInteractively = interactively;
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentAnimate:(id<UIViewControllerContextTransitioning>)context
         containerView:(UIView *)containerView
              fromView:(UIView *)fromView
                toView:(UIView *)toView
    fromViewController:(UIViewController *)fromViewController
      toViewController:(UIViewController *)toViewController
{
    [containerView addSubview:fromView];
    [containerView addSubview:toView];
    
    // store initial frame and parent view for restoration
    self.triggerViewFrame = [self.triggerView.superview convertRect:self.triggerView.frame toView:containerView];
    self.triggerViewParentView = self.triggerView.superview;
    
    // prepare before anaimation
    toView.frame = self.triggerViewFrame;
    [self.presentedViewController preparePresentAnimation:self.triggerView];
    
    self.triggerView.frame = [containerView convertRect:self.triggerViewFrame toView:self.triggerView.superview];
    
    // do present animation
    [UIView animateWithDuration:[self transitionDuration:context] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        toView.frame = [context finalFrameForViewController:toViewController];
        [self.presentedViewController performPresentAnimation:self.triggerView];
    } completion:^(BOOL finished) {
        [fromView removeFromSuperview];
        [context completeTransition:YES];
    }];
}

- (void)dismissAnimate:(id<UIViewControllerContextTransitioning>)context
         containerView:(UIView *)containerView
              fromView:(UIView *)fromView
                toView:(UIView *)toView
    fromViewController:(UIViewController *)fromViewController
      toViewController:(UIViewController *)toViewController
{
    [containerView addSubview:toView];
    [containerView addSubview:fromView];
    fromView.frame = [context initialFrameForViewController:fromViewController];
    
    [UIView animateKeyframesWithDuration:[self transitionDuration:context] delay:0 options:0 animations:^{
        // 1. shrink detail view
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            CGPoint oldCenter = fromView.center;
            fromView.width *= 0.7;
            fromView.height *= 0.7;
            fromView.center = oldCenter;
            [fromView layoutIfNeeded];
        }];
        
        // 2. dismiss detail view, shrink trigger view back to its original position
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            fromView.frame = self.triggerViewFrame;
            self.triggerView.frame = [containerView convertRect:self.triggerViewFrame toView:self.triggerView.superview];
        }];
    } completion:^(BOOL finished) {
        if (!context.transitionWasCancelled) {
            self.triggerView.frame = [containerView convertRect:self.triggerViewFrame toView:self.triggerViewParentView];
            [self.triggerViewParentView addSubview:self.triggerView];
            [fromView removeFromSuperview];
        } else {
            // only restore first stage of animation
            // second stage of animation is ireversable
            // it should be controlled by interaction control logic
            [toView removeFromSuperview];
        }
        [context completeTransition:!context.transitionWasCancelled];
    }];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (fromViewController == self.presentingViewController) {
        [self presentAnimate:transitionContext
               containerView:transitionContext.containerView
                    fromView:[transitionContext viewForKey:UITransitionContextFromViewKey]
                      toView:[transitionContext viewForKey:UITransitionContextToViewKey]
          fromViewController:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]
            toViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    } else {
        [self dismissAnimate:transitionContext
               containerView:transitionContext.containerView
                    fromView:[transitionContext viewForKey:UITransitionContextFromViewKey]
                      toView:[transitionContext viewForKey:UITransitionContextToViewKey]
          fromViewController:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]
            toViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return .5;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if (self.dismissInteractively) {
        return self;
    } else {
        return nil;
    }
}

- (void)cancelInteractiveTransition
{
    [super cancelInteractiveTransition];
    
    for (UIView *view in self.presentedViewController.view.superview.subviews) {
        if (view != self.presentedViewController.view) {
            [view removeFromSuperview];
        }
    }
}

@end
