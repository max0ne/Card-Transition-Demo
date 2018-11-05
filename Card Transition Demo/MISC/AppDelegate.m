//
//  AppDelegate.m
//  Card Transition Demo
//
//  Created by Mingfei Huang on 11/4/18.
//  Copyright © 2018 Mingfei Huang. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [UIWindow new];
    [window makeKeyAndVisible];
    window.backgroundColor = [UIColor orangeColor];
    window.rootViewController = [NSClassFromString(@"ListVC") new];
    self.window = window;
    return YES;
}

@end
