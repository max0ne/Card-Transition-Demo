//
//  KAKAnimation.swift
//  Card Transition Demo
//
//  Created by Mingfei Huang on 11/4/18.
//  Copyright © 2018 Mingfei Huang. All rights reserved.
//

import YYKit

protocol KAKAnimationPresentingViewController: NSObjectProtocol {
    /**
     *  a callback to presenting view controller by end of dismissal animation
     *  called after trigger view has been passed back to its original view hierarchy
     */
    func completeDismissAnimation(_ triggerView: UIView)
}

protocol KAKAnimationPresentedViewController: NSObjectProtocol {
    /**
     *  a callback to presented view controller by begining of present animation
     *  presented view controller should use this callback to install trigger view into its view hierarchy
     */
    func preparePresentAnimation(_ triggerView: UIView)
    
    /**
     *  a callback to presented view controller by end of present animation
     *  presented view controller should apply finalized style to trigger view
     */
    func performPresentAnimation(_ triggerView: UIView)
}


class KAKAnimation: UIPercentDrivenInteractiveTransition {
    var triggerViewFrame: CGRect?
    var triggerViewParentView: UIView?
    
    var triggerView: UIView
    var presentingViewController: (KAKAnimationPresentingViewController & UIViewController)
    var presentedViewController: (KAKAnimationPresentedViewController & UIViewController)
    
    private var dismissInteractively = false
    
    init(
        triggerView: UIView,
        presentingViewController: (KAKAnimationPresentingViewController & UIViewController),
        presentedViewController: (KAKAnimationPresentedViewController & UIViewController)
        ) {
        self.triggerView = triggerView
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        super.init()
    }
    
    func dismiss(interactively: Bool) {
        self.dismissInteractively = interactively
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}

extension KAKAnimation: UIViewControllerAnimatedTransitioning {
    func presentAnimateWith(
        context: UIViewControllerContextTransitioning,
        containerView: UIView,
        fromView: UIView,
        toView: UIView,
        fromViewController: UIViewController,
        toViewController: UIViewController
        )
    {
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        
        // store initial frame and parent view for restoration
        self.triggerViewFrame = self.triggerView.superview?.convert(self.triggerView.frame, to: containerView)
        self.triggerViewParentView = self.triggerView.superview
        
        // prepare before anaimation
        toView.frame = self.triggerViewFrame!
        self.presentedViewController.preparePresentAnimation(self.triggerView)
        
        self.triggerView.frame = containerView.convert(self.triggerViewFrame!, to: self.triggerView.superview)
        
        // do present animation
        UIView.animate(withDuration: self.transitionDuration(using: context), animations: {
            toView.frame = context.finalFrame(for: toViewController)
            self.presentedViewController.performPresentAnimation(self.triggerView)
        }) { (_) in
            fromView.removeFromSuperview()
            context.completeTransition(true)
        }
    }
    
    func dismissAnimateWith(
        context: UIViewControllerContextTransitioning,
        containerView: UIView,
        fromView: UIView,
        toView: UIView,
        fromViewController: UIViewController,
        toViewController: UIViewController
        )
    {
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        fromView.frame = context.initialFrame(for: fromViewController)
        let triggerViewFrame = self.triggerViewFrame ?? CGRect.zero
        
        UIView.animateKeyframes(withDuration: self.transitionDuration(using: context), delay: 0, options: [], animations: {
            
            // 1. shrink detail view
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                let oldCenter = fromView.center
                fromView.width *= 0.7
                fromView.height *= 0.7
                fromView.center = oldCenter
                fromView.layoutIfNeeded()
            })
            
            // 2. dismiss detail view, shrink trigger view back to its original position
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                fromView.frame = self.triggerViewFrame ?? CGRect.zero
                self.triggerView.frame = containerView.convert(triggerViewFrame, to: self.triggerView.superview)
            })
        }) { (completed) in
            if (context.transitionWasCancelled) {
                toView.removeFromSuperview()
            } else {
                self.triggerView.frame = containerView.convert(triggerViewFrame, to: self.triggerViewParentView)
                self.triggerViewParentView?.addSubview(self.triggerView)
                fromView.removeFromSuperview()
            }
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        if (fromViewController == self.presentingViewController) {
            self.presentAnimateWith(context: transitionContext,
                                    containerView: transitionContext.containerView,
                                    fromView: transitionContext.view(forKey: UITransitionContextViewKey.from)!,
                                    toView: transitionContext.view(forKey: UITransitionContextViewKey.to)!,
                                    fromViewController: transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!,
                                    toViewController: transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        } else {
            self.dismissAnimateWith(context: transitionContext,
                                    containerView: transitionContext.containerView,
                                    fromView: transitionContext.view(forKey: UITransitionContextViewKey.from)!,
                                    toView: transitionContext.view(forKey: UITransitionContextViewKey.to)!,
                                    fromViewController: transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!,
                                    toViewController: transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
}

extension KAKAnimation: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if (self.dismissInteractively) {
            return self
        } else {
            return nil
        }
    }
}
