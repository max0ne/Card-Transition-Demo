//
//  KAKAnimation.h
//  Card Transition Demo
//
//  Created by Mingfei Huang on 11/4/18.
//  Copyright © 2018 Mingfei Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KAKAnimationPresentingViewController <NSObject>

@required

/**
 *  a callback to presenting view controller by end of dismissal animation
 *  called after trigger view has been passed back to its original view hierarchy
 */
- (void)completeDismissAnimation:(UIView *)triggerView;

@end

@protocol KAKAnimationPresentedViewController <NSObject>

@required

/**
 *  a callback to presented view controller by begining of present animation
 *  presented view controller should use this callback to install trigger view into its view hierarchy
 */
- (void)preparePresentAnimation:(UIView *)triggerView;

/**
 *  a callback to presented view controller by end of present animation
 *  presented view controller should apply finalized style to trigger view
 */
- (void)performPresentAnimation:(UIView *)triggerView;

@end

@interface KAKAnimation : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

+ (instancetype)instanceWithTriggerView:(UIView *)triggerView
               presentingViewController:(UIViewController<KAKAnimationPresentingViewController> *)presentingViewController
                presentedViewController:(UIViewController<KAKAnimationPresentedViewController> *)presentedViewController;

- (void)dismissInteractively:(BOOL)interactively;

@property (weak, nonatomic, readonly) UIView *triggerView;
@property (weak, nonatomic, readonly) UIViewController<KAKAnimationPresentingViewController> *presentingViewController;
@property (weak, nonatomic, readonly) UIViewController<KAKAnimationPresentedViewController> *presentedViewController;
@property (assign, nonatomic, readonly) BOOL dismissInteractively;

@end

NS_ASSUME_NONNULL_END
