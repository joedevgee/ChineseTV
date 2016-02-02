//
//  AppDelegate.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/9/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import Parse
import Bolts
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    struct ShareIdentity {
        static let WeChatAppId: String = "wx53128a7a7db966bf"
        static let QQAppId: String = "1104904597"
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Configure the look of navBar
        let navBar = UINavigationBar.appearance()
        navBar.barTintColor = themeColor
        navBar.tintColor = UIColor.whiteColor()
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.translucent = false
        navBar.shadowImage = UIImage()
        // End of configuring navBar
        
        // Configure the look of tabbar
        let tabBar = UITabBar.appearance()
        tabBar.tintColor = themeColor
        tabBar.barTintColor = UIColor.whiteColor()
        tabBar.shadowImage = UIImage()
        // End of tabbar configure
        
        // Configure parse related items
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("IhDPuqiPOkNK0rHuHn2q2XNxgG3o5J0uTf2JoCbD",
            clientKey: "C6mZr78yxdgJFrRROfpbntpqItBQKwnKhedFehVz")
        
        // Set the status bar style
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // facebook app events
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Register for Chinese social media share
        swizzle()
        RSWeChat.register(ShareIdentity.WeChatAppId)
        RSWeChat.register(ShareIdentity.QQAppId)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if let share = ShareManager.getShare(scheme: url.scheme) {
            return share.handleOpenURL(url)
        } else {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func swizzle() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            let originalSelector = Selector("openURL:")
            let swizzledSelector = Selector("hook_openURL:")
            
            let originalMethod: IMP = UIApplication.instanceMethodForSelector(originalSelector)
            let swizzledMethod = UIApplication.instanceMethodForSelector(swizzledSelector)
            
            class_replaceMethod(UIApplication.self, originalSelector, swizzledMethod, nil)
            class_replaceMethod(UIApplication.self, swizzledSelector, originalMethod, nil)
            
        }
    }

}

extension UIApplication {
    func hook_openURL(url: NSURL) -> Bool {
        print("hooking open url: \(url)")
        return self.hook_openURL(url)
    }
}

