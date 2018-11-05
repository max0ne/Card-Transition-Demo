//
//  AppDelegate.swift
//  Card Transition Demo
//
//  Created by Mingfei Huang on 11/4/18.
//  Copyright © 2018 Mingfei Huang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = UIColor.orange
        self.window?.rootViewController = ListVC()
    }
}
