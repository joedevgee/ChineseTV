//
//  PlayListDetailViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/11/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import XCDYouTubeKit
import MediaPlayer


class PlayListDetailViewController: UIViewController {
    
    var playListId:String?
    var playVideoId:String?
    
    var topContainer:UIView = UIView.newAutoLayoutView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topContainer.backgroundColor = UIColor.blackColor()
        self.view.addSubview(topContainer)
        topContainer.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
        topContainer.autoPinEdgeToSuperviewEdge(.Left)
        topContainer.autoPinEdgeToSuperviewEdge(.Right)
        topContainer.autoSetDimension(.Height, toSize: UIScreen.mainScreen().bounds.width*0.75)
        
        self.playYoutube()
        
    }
    
    func playYoutube() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterFullScreen", name: MPMoviePlayerWillEnterFullscreenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willExitFullScreen", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        
        
        let videoPlayer = XCDYouTubeVideoPlayerViewController(videoIdentifier: "hfzUOLCUZxc")
        videoPlayer.presentInView(topContainer)
        videoPlayer.moviePlayer.play()
        
        let closeButton = UIButton()
        closeButton.addTarget(self, action: Selector("exitViewController"), forControlEvents: .TouchUpInside)
        let closeImage = UIImage(named:"ic_clear")?.imageWithRenderingMode(
            UIImageRenderingMode.AlwaysTemplate)
        closeButton.tintColor = UIColor.whiteColor()
        closeButton.setImage(closeImage, forState: .Normal)
        videoPlayer.moviePlayer.view.addSubview(closeButton)
        videoPlayer.moviePlayer.view.backgroundColor = UIColor.whiteColor()
        
        closeButton.autoPinEdgeToSuperviewEdge(.Top)
        closeButton.autoPinEdgeToSuperviewEdge(.Left)
        
    }
    
    func willEnterFullScreen() {
        print("Entering full screen")
        let value = UIInterfaceOrientation.LandscapeRight.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    func willExitFullScreen() {
        print("Exiting full screen")
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func exitViewController() {
        print("button pressed")
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        dismissViewControllerAnimated(true, completion: nil)
    }

}

