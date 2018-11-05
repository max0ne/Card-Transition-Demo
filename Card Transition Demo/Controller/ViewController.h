//
//  ViewController.h
//  Card Transition Demo
//
//  Created by Mingfei Huang on 11/4/18.
//  Copyright © 2018 Mingfei Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KAKAnimation;

NS_ASSUME_NONNULL_BEGIN

@interface ListVC : UIViewController

@end

@interface DetailVC : UIViewController

+ (instancetype)instanceWithLaunchingAnimation:(KAKAnimation *)anime;

@property (strong, nonatomic) KAKAnimation *anime;

@end


NS_ASSUME_NONNULL_END
