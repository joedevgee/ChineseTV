//
//  AppDelegate.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/15/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import Parse
import Bolts
import FBSDKCoreKit
import ParseFacebookUtilsV4
import Fabric
import TwitterKit
import ParseTwitterUtils

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // Configure the look of navBar
        let navBar = UINavigationBar.appearance()
        navBar.barTintColor = sideMenuColor
        navBar.tintColor = UIColor.whiteColor()
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        // End of configuring navBar
        
        // Connect with facebook sdk
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Connect with twitter sdk
        Fabric.with([Twitter.self])
        PFTwitterUtils.initializeWithConsumerKey("Np0LDF5wEjee5OD1owS6RWdLA",  consumerSecret:"GPlDRwMTVxKJlV6MG64dyH3xoyhnFq0SKsc6nHckZplkdcolGo")
        
        // Configure parse related items
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("IhDPuqiPOkNK0rHuHn2q2XNxgG3o5J0uTf2JoCbD",
            clientKey: "C6mZr78yxdgJFrRROfpbntpqItBQKwnKhedFehVz")
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        // End of configuring parse
        
        // Set the status bar style
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        return true
    }
    
    // For facebook
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
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


}

