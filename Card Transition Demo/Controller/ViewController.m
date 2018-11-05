//
//  ViewController.m
//  Card Transition Demo
//
//  Created by Mingfei Huang on 11/4/18.
//  Copyright © 2018 Mingfei Huang. All rights reserved.
//

#import "ViewController.h"

#import <YYKit/YYKit.h>

#import "KAKAnimation.h"

@interface ListVC () <KAKAnimationPresentingViewController>

@property (strong, nonatomic) KAKAnimation *currentAnimation;

@end

@interface DetailVC () <KAKAnimationPresentedViewController, UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation ListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setupCardView];
}

- (void)setupCardView
{
    NSString *imageUrl = @"https://source.unsplash.com/random";
    
    UIImageView *cardView = [UIImageView new];
    [cardView setImageWithURL:[NSURL URLWithString:imageUrl] options:YYWebImageOptionRefreshImageCache];
    cardView.width = cardView.height = 200;
    cardView.contentMode = UIViewContentModeScaleAspectFill;
    cardView.layer.cornerRadius = 8;
    cardView.clipsToBounds = YES;
    cardView.userInteractionEnabled = YES;
    cardView.center = self.view.center;
    cardView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:cardView];
    
    __weak typeof(cardView) weak_cardView = cardView;
    __weak typeof(self) weak_self = self;
    
    [cardView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        if (weak_self.view.window) {
            DetailVC *detailVC = [DetailVC instanceWithLaunchingAnimation:weak_self.currentAnimation];
            weak_self.currentAnimation = [KAKAnimation instanceWithTriggerView:weak_cardView
                                                      presentingViewController:weak_self
                                                       presentedViewController:detailVC];
            detailVC.anime = weak_self.currentAnimation;
            detailVC.transitioningDelegate = weak_self.currentAnimation;
            [weak_self presentViewController:detailVC animated:YES completion:nil];
        } else {
            [weak_self.currentAnimation dismissInteractively:NO];
        }
    }]];
}

- (void)completeDismissAnimation:(UIView *)triggerView
{
    triggerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
}

@end

@implementation DetailVC

+ (instancetype)instanceWithLaunchingAnimation:(KAKAnimation *)anime
{
    DetailVC *inst = self.new;
    inst.anime = anime;
    return inst;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.frame = self.view.bounds;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.bounces = NO;
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    UIPanGestureRecognizer *gest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:gest];
}

- (void)preparePresentAnimation:(UIView *)triggerView
{
    [self.scrollView addSubview:triggerView];
}

- (void)performPresentAnimation:(UIView *)triggerView
{
    triggerView.frame = CGRectMake(0, 0, self.view.width, 400);
    triggerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    CGFloat percentage = [gesture translationInView:self.view].y / 200;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (percentage > 0) {
            [self.anime dismissInteractively:YES];
        } else {
            gesture.enabled = NO;
            gesture.enabled = YES;
        }
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self.anime updateInteractiveTransition:percentage];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (percentage > 0.5) {
            [self.anime finishInteractiveTransition];
        } else {
            [self.anime cancelInteractiveTransition];
        }
    }
}

@end
