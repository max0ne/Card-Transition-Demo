//
//  ViewController.swift
//  Card Transition Demo
//
//  Created by Mingfei Huang on 11/4/18.
//  Copyright © 2018 Mingfei Huang. All rights reserved.
//

import YYKit

class ListVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        self.setupCardView()
    }
    
    func setupCardView() {
        let imageUrl = "https://source.unsplash.com/random"
        let cardView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        cardView.setImageWith(URL(string: imageUrl), options: YYWebImageOptions.refreshImageCache)
        cardView.contentMode = UIView.ContentMode.scaleAspectFill
        cardView.layer.cornerRadius = 8
        cardView.clipsToBounds = true
        cardView.isUserInteractionEnabled = true
        cardView.center = self.view.center
        cardView.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleBottomMargin
        ]
        self.view.addSubview(cardView)
        
        var currentAnimation: KAKAnimation!
        cardView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { [unowned self, cardView] (_) in
            if (self.view.window != nil) {
                let detailVC = DetailVC(nibName: nil, bundle: nil)
                currentAnimation = KAKAnimation(triggerView: cardView,
                                         presentingViewController: self,
                                         presentedViewController: detailVC)
                detailVC.anime = currentAnimation
                detailVC.transitioningDelegate = currentAnimation
                self.present(detailVC, animated: true, completion: nil)
            } else {
                currentAnimation.dismiss(interactively: false)
            }
        }))
    }
    
}

extension ListVC: KAKAnimationPresentingViewController {
    func completeDismissAnimation(_ triggerView: UIView) {
        triggerView.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleBottomMargin
        ]
    }
}

class DetailVC: UIViewController {
    var anime: KAKAnimation!
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.setupScrollView()
        self.setupDismissGesture()
    }
    
    func setupScrollView() {
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.bounces = false
        self.view.addSubview(scrollView)
    }
    
    func setupDismissGesture() {
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:))))
    }
    
    @objc
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let percentage = gesture.translation(in: self.view).y / 200
        if (gesture.state == .began) {
            if (percentage > 0) {
                self.anime.dismiss(interactively: true)
            } else {
                gesture.isEnabled = false
                gesture.isEnabled = true
            }
        } else if (gesture.state == .changed) {
            self.anime.update(percentage)
        } else if (gesture.state == .ended || gesture.state == .cancelled) {
            if (percentage > 0.5) {
                self.anime.finish()
            } else {
                self.anime.cancel()
            }
        }
    }
}

extension DetailVC: KAKAnimationPresentedViewController {
    func preparePresentAnimation(_ triggerView: UIView) {
        self.scrollView.addSubview(triggerView)
    }
    
    func performPresentAnimation(_ triggerView: UIView) {
        triggerView.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 400)
        triggerView.autoresizingMask = [
            .flexibleWidth,
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleBottomMargin
        ]
    }
}
