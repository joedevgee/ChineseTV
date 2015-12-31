//
//  RootViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/10/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit

class RootViewController: RESideMenu, RESideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        
        self.scaleContentView = false
        
        self.contentViewInPortraitOffsetCenterX = 0
        self.menuPreferredStatusBarStyle = UIStatusBarStyle.LightContent
        self.contentViewShadowColor = UIColor.clearColor()
        self.contentViewShadowOffset = CGSizeMake(0, 0);
        self.contentViewShadowOpacity = 0.6;
        self.contentViewShadowRadius = 12;
        self.contentViewShadowEnabled = true;
        
        self.delegate = self
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        self.contentViewController = storyBoard.instantiateViewControllerWithIdentifier("ContentViewController") as UIViewController
        self.leftMenuViewController = storyBoard.instantiateViewControllerWithIdentifier("LeftMenuViewController") as UIViewController
        
    }
    
    // MARK: RESide Delegate Methods
    
    func sideMenu(sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!) {
//        print("This will show the menu")
    }
    
    func sideMenu(sideMenu: RESideMenu!, didHideMenuViewController menuViewController: UIViewController!) {
        //
    }
    
    func sideMenu(sideMenu: RESideMenu!, willHideMenuViewController menuViewController: UIViewController!) {
        //
    }
    
    
}
