//
//  AppDelegate.swift
//  demoCrash
//
//  Created by mtAdmin on 2021/6/13.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DoraemonCrashSignalExceptionHandler.register()
        DoraemonCrashUncaughtExceptionHandler.register()
        
        return true
    }

}

