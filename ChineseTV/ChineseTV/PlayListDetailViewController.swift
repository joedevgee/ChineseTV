//
//  PlayListDetailViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/11/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//
import Foundation
import UIKit
import SDWebImage
import PureLayout
import XCDYouTubeKit
import Alamofire
import Async
import FontAwesomeKit
import FBSDKCoreKit
import FBSDKLoginKit
import Parse
import ParseUI
import TTGSnackbar
import NVActivityIndicatorView
import GoogleMobileAds

class PlayListDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FBSDKLoginButtonDelegate, UITextViewDelegate, GADBannerViewDelegate, SignUpViewControllerDelegate {
    
    var currentListId:String?
    var parseListId:String?
    
    var nextVideoPageToken:String?
    var videoTokenCheck = [String: Bool]()
    
    var nextCommentPageToken:String?
    var commentTokenCheck = [String: Bool]()
    
    var videoList: [Video] = []
    var commentList: [Comment] = []
    
    var topContainer:UIView = UIView.newAutoLayoutView()
    var videoContainer:UIView = UIView.newAutoLayoutView()
    var youtubePlayer = XCDYouTubeVideoPlayerViewController()
    var pacMan = NVActivityIndicatorView(frame: CGRectZero, type: .Pacman, color: UIColor.whiteColor(), size: CGSize(width: 35, height: 35))
    var playerCloseButton:UIButton = UIButton.newAutoLayoutView()
    var videoSubContainer:UIView = UIView.newAutoLayoutView()
    
    var videoListButton:UIButton = UIButton.newAutoLayoutView()
    var videoButtonUnderline:UIView = UIView.newAutoLayoutView()
    var commentListButton:UIButton = UIButton.newAutoLayoutView()
    var commentButtonUnderline:UIView = UIView.newAutoLayoutView()
    
    var videoListTableView:UITableView = UITableView.newAutoLayoutView()
    var videoListHeaderTitle:UILabel = UILabel.newAutoLayoutView()
    var commentListTableView:UITableView = UITableView.newAutoLayoutView()
    let commentShareButton:UIButton = UIButton.newAutoLayoutView()
    let videoShareButton:UIButton = UIButton.newAutoLayoutView()
    var fbLoginButton:FBSDKLoginButton = FBSDKLoginButton.newAutoLayoutView()
    var loginInfoLabel:UILabel = UILabel.newAutoLayoutView()
    var fbProfileView:FBSDKProfilePictureView = FBSDKProfilePictureView.newAutoLayoutView()
    var parseAvatarView:PFImageView = PFImageView.newAutoLayoutView()
    var commentTextView:UITextView = UITextView.newAutoLayoutView()
    var sendCommentButton:UIButton = UIButton.newAutoLayoutView()
    
    // To comply with Apple review rules, build own user system
    var registerButton:UIButton = UIButton.newAutoLayoutView()
    
    var didSetupConstraints = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show comment list first
        self.showCommentList()
        
        // add gesture to swipe back
        let swipeRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "exitViewController")
        swipeRecognizer.direction = .Right
        view.addGestureRecognizer(swipeRecognizer)
        
        // Check if user logged in through facebook
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        if FBSDKAccessToken.currentAccessToken() != nil {
            // Already signed in through facebook
            self.fbProfileView.hidden = false
            self.fbLoginButton.hidden = true
            self.loginInfoLabel.hidden = true
            self.commentTextView.hidden = false
            self.sendCommentButton.hidden = true
            self.registerButton.hidden = true
        } else {
            self.fbProfileView.hidden = true
            self.commentTextView.hidden = true
            self.sendCommentButton.hidden = true
            self.fbLoginButton.hidden = false
            self.loginInfoLabel.hidden = false
            if let userID:String = NSUserDefaults.standardUserDefaults().valueForKey("userID") as? String { parseRegistered(userID) }
        }
        // Observe for profile change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeProfile", name: FBSDKProfileDidChangeNotification, object: nil)
        // Observe for user registering with Parse
        
    }
    
    // GADBanner view delegate
    
    
    // MARK: Setup the UI
    
    override func loadView() {
        view = UIView()
        view.addSubview(topContainer)
        view.addSubview(videoListTableView)
        view.addSubview(commentListTableView)
        
        self.setupTopContainer()
        self.setupVideoPlayer()
        self.setupCommentList()
        self.setupVideoList()
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if !self.didSetupConstraints {
            // Configure auto layout constraints for top container
            commentListButton.autoPinEdgeToSuperviewEdge(.Left)
            commentListButton.autoPinEdgeToSuperviewEdge(.Top)
            commentListButton.autoPinEdgeToSuperviewEdge(.Bottom)
            commentListButton.autoMatchDimension(.Width, toDimension: .Width, ofView: videoSubContainer, withMultiplier: 0.5)
            
            videoListButton.autoPinEdgeToSuperviewEdge(.Top)
            videoListButton.autoPinEdgeToSuperviewEdge(.Right)
            videoListButton.autoPinEdgeToSuperviewEdge(.Bottom)
            videoListButton.autoPinEdge(.Left, toEdge: .Right, ofView: commentListButton)
            
            videoButtonUnderline.autoSetDimension(.Height, toSize: 2)
            videoButtonUnderline.autoPinEdgeToSuperviewEdge(.Bottom)
            videoButtonUnderline.autoPinEdgeToSuperviewEdge(.Leading)
            videoButtonUnderline.autoPinEdgeToSuperviewEdge(.Trailing)
            
            commentButtonUnderline.autoSetDimension(.Height, toSize: 2)
            commentButtonUnderline.autoPinEdgeToSuperviewEdge(.Leading)
            commentButtonUnderline.autoPinEdgeToSuperviewEdge(.Trailing)
            commentButtonUnderline.autoPinEdgeToSuperviewEdge(.Bottom)
            
            // Configure auto layout constraints for video player
            pacMan.autoCenterInSuperview()
            playerCloseButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
            playerCloseButton.autoPinEdgeToSuperviewEdge(.Left)
            
            // Configure auto layout constraints for comment list
            fbProfileView.autoSetDimensionsToSize(CGSize(width: 30, height: 30))
            fbProfileView.autoPinEdgeToSuperviewEdge(.Top, withInset: 8, relation: .LessThanOrEqual)
            fbProfileView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 5, relation: .LessThanOrEqual)
            
            parseAvatarView.autoSetDimensionsToSize(CGSize(width: 30, height: 30))
            parseAvatarView.autoPinEdgeToSuperviewEdge(.Top, withInset: 8, relation: .LessThanOrEqual)
            parseAvatarView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 5, relation: .LessThanOrEqual)
            
            commentShareButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 10, relation: .LessThanOrEqual)
            commentShareButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5, relation: .LessThanOrEqual)
            
            sendCommentButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
            sendCommentButton.autoAlignAxis(.Vertical, toSameAxisOfView: commentShareButton)
            
            loginInfoLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 12, relation: .LessThanOrEqual)
            loginInfoLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            
            fbLoginButton.autoCenterInSuperview()
            
            registerButton.autoPinEdgeToSuperviewEdge(.Left, withInset: 10, relation: .LessThanOrEqual)
            registerButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5, relation: .LessThanOrEqual)
            
            commentTextView.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
            commentTextView.autoPinEdge(.Left, toEdge: .Right, ofView: fbProfileView, withOffset: 5)
            commentTextView.autoPinEdge(.Right, toEdge: .Left, ofView: sendCommentButton, withOffset: -5)
            commentTextView.autoPinEdge(.Bottom, toEdge: .Top, ofView: commentShareButton, withOffset: -2)
            
            commentListTableView.estimatedRowHeight = 50
            commentListTableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topContainer)
            commentListTableView.autoPinEdgeToSuperviewEdge(.Left)
            commentListTableView.autoPinEdgeToSuperviewEdge(.Right)
            commentListTableView.autoPinEdgeToSuperviewEdge(.Bottom)
            
            // Configure auto layout constraints for video list
            videoListHeaderTitle.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
            videoListHeaderTitle.autoSetDimension(.Width, toSize: UIScreen.mainScreen().bounds.width*0.9, relation: .LessThanOrEqual)
            videoListHeaderTitle.autoAlignAxisToSuperviewMarginAxis(.Vertical)
            
            videoShareButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 10, relation: .LessThanOrEqual)
            videoShareButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5, relation: .LessThanOrEqual)
            
            videoListTableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topContainer)
            videoListTableView.autoPinEdgeToSuperviewEdge(.Left)
            videoListTableView.autoPinEdgeToSuperviewEdge(.Right)
            videoListTableView.autoPinEdgeToSuperviewEdge(.Bottom)
            
            self.didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
    
    
    
    func setupTopContainer() {
        
        topContainer.backgroundColor = UIColor.clearColor()
        topContainer.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
        topContainer.autoPinEdgeToSuperviewEdge(.Left)
        topContainer.autoPinEdgeToSuperviewEdge(.Right)
        topContainer.autoSetDimension(.Height, toSize: UIScreen.mainScreen().bounds.width*0.70)
        
        videoContainer.backgroundColor = UIColor.blackColor()
        self.topContainer.addSubview(videoContainer)
        videoContainer.autoSetDimension(.Height, toSize: UIScreen.mainScreen().bounds.width*0.60)
        videoContainer.autoPinEdgeToSuperviewEdge(.Left)
        videoContainer.autoPinEdgeToSuperviewEdge(.Right)
        videoContainer.autoPinEdgeToSuperviewEdge(.Top)
        
        videoSubContainer.backgroundColor = videoTopColor
        self.topContainer.addSubview(videoSubContainer)
        videoSubContainer.autoPinEdgeToSuperviewEdge(.Left)
        videoSubContainer.autoPinEdgeToSuperviewEdge(.Right)
        videoSubContainer.autoPinEdgeToSuperviewEdge(.Bottom)
        videoSubContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: videoContainer)
        
        videoListButton.backgroundColor = UIColor.clearColor()
        videoListButton.setTitle("视频列表", forState: .Normal)
        videoListButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        videoListButton.titleLabel?.textAlignment = .Center
        videoListButton.addTarget(self, action: "showVideoList", forControlEvents: .TouchUpInside)
        
        videoButtonUnderline.backgroundColor = UIColor.whiteColor()
        videoButtonUnderline.hidden = true
        
        commentListButton.backgroundColor = UIColor.clearColor()
        commentListButton.setTitle("剧透聊天", forState: .Normal)
        commentListButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        commentListButton.titleLabel?.textAlignment = .Center
        commentListButton.addTarget(self, action: "showCommentList", forControlEvents: .TouchUpInside)
        
        commentButtonUnderline.backgroundColor = UIColor.whiteColor()
        commentButtonUnderline.hidden = true
        
        videoSubContainer.addSubview(videoListButton)
        videoSubContainer.addSubview(commentListButton)
        
        videoListButton.addSubview(videoButtonUnderline)
        commentListButton.addSubview(commentButtonUnderline)
        
    }
    
    func setupVideoPlayer() {
        // Use below notifications to detect when user entered or exited full-screen mode
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterFullScreen", name: MPMoviePlayerWillEnterFullscreenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willExitFullScreen", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        // Remove this notification so player doesn't dismiss automatically at the end of video
        NSNotificationCenter.defaultCenter().removeObserver(youtubePlayer, name: MPMoviePlayerPlaybackDidFinishNotification, object: youtubePlayer.moviePlayer)
        // Add observer to handle changing video
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("changeVideo:"), name: XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification, object: nil)
        // Add observer to handle playback state change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerStateChange", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: nil)
        // Add observer to handle load state change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerStateChange", name: MPMoviePlayerLoadStateDidChangeNotification, object: nil)
        
        youtubePlayer.presentInView(self.videoContainer)
        youtubePlayer.moviePlayer.cancelAllThumbnailImageRequests()
        youtubePlayer.moviePlayer.shouldAutoplay = true
        youtubePlayer.moviePlayer.scalingMode = .AspectFill
        
        playerCloseButton.addTarget(self, action: Selector("exitViewController"), forControlEvents: .TouchUpInside)
        let closeImage = UIImage(named:"ic_clear")?.imageWithRenderingMode(
            UIImageRenderingMode.AlwaysTemplate)
        playerCloseButton.tintColor = UIColor.whiteColor()
        playerCloseButton.setImage(closeImage, forState: .Normal)
        youtubePlayer.moviePlayer.view.addSubview(playerCloseButton)
        
        // Add a activity indicator to show that video is being loaded
        pacMan.hidden = true
        pacMan.startAnimation()
        youtubePlayer.moviePlayer.view.addSubview(pacMan)
        
    }
    
    func setupVideoList() {
        self.videoListTableView.delegate = self
        self.videoListTableView.dataSource = self
        self.videoListTableView.registerClass(VideoListTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.videoListTableView.registerClass(VideoAdListTableViewCell.self, forCellReuseIdentifier: "AdCell")
        self.videoListTableView.separatorStyle = .None
        self.videoListTableView.backgroundColor = videoSubColor
        
        let videoListHeader:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,120))
        videoListHeader.backgroundColor = videoTopColor
        
        videoListHeaderTitle.text = ""
        videoListHeaderTitle.textColor = UIColor.whiteColor()
        videoListHeaderTitle.lineBreakMode = .ByTruncatingTail
        videoListHeaderTitle.font = UIFont.boldSystemFontOfSize(15)
        videoListHeaderTitle.textAlignment = .Left
        videoListHeaderTitle.numberOfLines = 3
        videoListHeaderTitle.sizeToFit()
        
        videoShareButton.setTitle("分享", forState: .Normal)
        videoShareButton.backgroundColor = UIColor.clearColor()
        videoShareButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        videoShareButton.addTarget(self, action: "showSocialPopup", forControlEvents: .TouchUpInside)
        
        videoListHeader.addSubview(videoListHeaderTitle)
        videoListHeader.addSubview(videoShareButton)
        
        videoListTableView.tableHeaderView = videoListHeader
        videoListTableView.hidden = true
        
    }
    
    func showVideoList() {
        self.videoListTableView.hidden = false
        self.videoButtonUnderline.hidden = false
        self.commentButtonUnderline.hidden = true
        self.commentListTableView.hidden = true
        for video in self.videoList {
            if video.id == self.youtubePlayer.videoIdentifier {
                self.videoListHeaderTitle.text = "正在播放： " + video.name
            }
        }
    }
    
    func setupCommentList() {
        self.commentListTableView.delegate = self
        self.commentListTableView.dataSource = self
        self.commentListTableView.registerClass(VideoDetailCommentCell.self, forCellReuseIdentifier: "Cell")
        self.commentListTableView.registerClass(VideoDetailCommentAdCell.self, forCellReuseIdentifier: "AdCell")
        self.commentListTableView.separatorStyle = .None
        self.commentListTableView.backgroundColor = videoTopColor
        self.commentListTableView.allowsSelection = false
        
        // add gesture to dismiss keyboard
        let tapDismiss:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        commentListTableView.addGestureRecognizer(tapDismiss)
        
        let commentListHeader:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,120))
        commentListHeader.backgroundColor = videoTopColor
        
        commentListTableView.tableHeaderView = commentListHeader
        commentListTableView.hidden = false
        
        commentTextView.delegate = self
        commentTextView.text = "请在此输入您的回复。。。"
        commentTextView.textColor = UIColor.lightTextColor()
        commentTextView.backgroundColor = lighterThemeColor
        commentTextView.layer.cornerRadius = 5
        fbProfileView.layer.borderWidth = 0.1
        fbProfileView.layer.masksToBounds = true
        fbProfileView.layer.cornerRadius = 15
        fbProfileView.clipsToBounds = true
        fbProfileView.hidden = true
        parseAvatarView.layer.borderWidth = 0.1
        parseAvatarView.layer.masksToBounds = true
        parseAvatarView.layer.cornerRadius = 15
        parseAvatarView.clipsToBounds = true
        parseAvatarView.contentMode = .ScaleAspectFill
        parseAvatarView.hidden = true
        
        sendCommentButton.setTitle("发送", forState: .Normal)
        sendCommentButton.setTitleColor(videoTopColor, forState: .Disabled)
        sendCommentButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sendCommentButton.sizeToFit()
        sendCommentButton.hidden = true
        sendCommentButton.addTarget(self, action: "sendComment", forControlEvents: .TouchUpInside)
        
        commentShareButton.setTitle("分享", forState: .Normal)
        commentShareButton.backgroundColor = UIColor.clearColor()
        commentShareButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        commentShareButton.addTarget(self, action: "showSocialPopup", forControlEvents: .TouchUpInside)
        
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile"]
        loginInfoLabel.text = "登录后评论"
        loginInfoLabel.textColor = UIColor.whiteColor()
        loginInfoLabel.textAlignment = .Center
        loginInfoLabel.font = UIFont.boldSystemFontOfSize(15)
        
        registerButton.backgroundColor = UIColor.clearColor()
        registerButton.setTitle("注册", forState: .Normal)
        registerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        registerButton.addTarget(self, action: "showRegister:", forControlEvents: .TouchUpInside)
        
        commentListHeader.addSubview(fbProfileView)
        commentListHeader.addSubview(parseAvatarView)
        commentListHeader.addSubview(fbLoginButton)
        commentListHeader.addSubview(loginInfoLabel)
        commentListHeader.addSubview(commentTextView)
        commentListHeader.addSubview(sendCommentButton)
        commentListHeader.addSubview(commentShareButton)
        commentListHeader.addSubview(registerButton)
        
    }
    
    // MARK: textview delegate methods
    func textViewDidBeginEditing(textView: UITextView) {
        commentShareButton.hidden = true
        if textView.text == "请在此输入您的回复。。。" {
            textView.text = ""
            textView.backgroundColor = UIColor.whiteColor()
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        sendCommentButton.hidden = false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        sendCommentButton.hidden = true
        commentShareButton.hidden = false
        if textView.text.isEmpty {
            textView.text = "请在此输入您的回复。。。"
            textView.backgroundColor = lighterThemeColor
            textView.textColor = UIColor.lightTextColor()
        }
    }
    
    func sendComment() {
        if let sendingComment:String = self.commentTextView.text where !sendingComment.isEmpty {
            print(sendingComment)
            self.commentTextView.text = ""
            self.view.endEditing(true)
            // Retrieve info from facebook
            if FBSDKAccessToken.currentAccessToken() != nil && self.youtubePlayer.videoIdentifier != nil {
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name,id,picture"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                    if error == nil {
                        guard let name:NSString = result.valueForKey("name") as? NSString else { return }
                        guard let imageUrl:NSString = result.valueForKey("picture")!.valueForKey("data")?.valueForKey("url") as? NSString else { return }
                        self.savingComment(sendingComment, name: name as String, image: imageUrl as String, videoID: self.youtubePlayer.videoIdentifier!)
                    }
                })
                // End of retrieving info from facebook graph
            } else {
                // Not facebook user, use parse profile info
                guard let userName = NSUserDefaults.standardUserDefaults().stringForKey("userName") else { return }
                guard let imageUrl = NSUserDefaults.standardUserDefaults().stringForKey("userAvatarUrl") else { return }
                self.savingComment(sendingComment, name: userName, image: imageUrl, videoID: self.youtubePlayer.videoIdentifier!)
            }
        }
    }
    private func savingComment(text: String, name: String, image: String, videoID: String) {
        let savingComment = PFObject(className: "Comment")
        savingComment["text"] = text
        savingComment["name"] = name
        savingComment["imageUrl"] = image
        savingComment["videoId"] = videoID
        let newComment = Comment(name: name, avatarUrl: image, commentText: text)
        self.commentList.insert(newComment, atIndex: 0)
        self.commentListTableView.reloadData()
        savingComment.saveInBackgroundWithBlock {
            (success:Bool, error:NSError?) -> Void in
            if success {
                let successBar = TTGSnackbar.init(message: "您的回复已成功发送", duration: .Middle)
                successBar.show()
            }
        }
    }
    
    //MARK: facebook login button delegate methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if result.grantedPermissions.contains("public_profile") {
            print("User granted permission to app")
            self.fbProfileView.hidden = false
            self.commentTextView.hidden = false
            self.sendCommentButton.hidden = true
            self.loginInfoLabel.hidden = true
            self.fbLoginButton.hidden = true
            self.registerButton.hidden = true
        }
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out of facebook")
    }
    
    // Update profile picture
    func changeProfile() {
        self.fbProfileView.profileID = FBSDKAccessToken.currentAccessToken().userID
    }
    // Update the comment list header after user registered in Parse
    func parseRegistered(userID: String) {
        self.fbProfileView.hidden = true
        self.commentTextView.hidden = false
        self.registerButton.hidden = true
        self.sendCommentButton.hidden = true
        self.fbLoginButton.hidden = true
        self.loginInfoLabel.hidden = true
        // Query the user profile info from Parse
        let query = PFQuery(className: "UserProfile")
        query.getObjectInBackgroundWithId(userID) {
            (userProfile: PFObject?, error: NSError?) -> Void in
            if error == nil && userProfile != nil {
                let avatarPicture = userProfile!["avatar"] as! PFFile
                self.parseAvatarView.file = avatarPicture
                self.parseAvatarView.loadInBackground()
                self.parseAvatarView.hidden = false
            }
        }
    }
    
    func showCommentList() {
        self.commentButtonUnderline.hidden = false
        self.videoButtonUnderline.hidden = true
        self.videoListTableView.hidden = true
        self.commentListTableView.hidden = false
        if self.commentList.count == 0 {
            self.getVideoCommentsData(self.youtubePlayer.videoIdentifier!)
        }
    }
    
    // MARK: if user opt not to use facebook
    // provide option to register with our own user system
    func showRegister(sender: UIButton) {
        // Show the user register view controller
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("SignUp") as! SignUpViewController
        viewController.delegate = self
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = true
        formSheetController.allowDismissByPanningPresentedView = true
        formSheetController.presentationController?.contentViewSize = signUpViewSize
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    // MARK: signupview delegate
    func didPassSignUp(controller: SignUpViewController, userID: String) {
        self.parseRegistered(userID)
    }
    
    // MARK: XCDYouTubeKit delegate methods
    // Register as an observer of the movieplayer contentURL to automatically start playing the next video
    func changeVideo(notification: NSNotification) {
        Async.main {
            self.youtubePlayer.moviePlayer.prepareToPlay()
            self.youtubePlayer.moviePlayer.play()
            for video in self.videoList {
                if video.id == self.youtubePlayer.videoIdentifier {
                    self.videoListHeaderTitle.text = "正在播放： \(video.name)"
                }
            }
            }.background {
                self.getVideoCommentsData(self.youtubePlayer.videoIdentifier!)
                // Check if the current video is in a saved playlist
                guard let userList = NSUserDefaults.standardUserDefaults().arrayForKey(savedListArray) as? [String] else { return }
                if self.parseListId != nil {
                    switch userList.contains(self.parseListId!) {
                    case true:
                        self.updateSavedList()
                    case false:
                        print("User didnot saved this list, do nothing")
                    }
                }
        }
    }
    
    private func updateSavedList() {
        for video in self.videoList {
            if video.id == self.youtubePlayer.videoIdentifier && self.parseListId != nil {
                print("updating saved playlist")
                // update video name
                guard let nudSavedVideoNameDict:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoNameDict) as? [String: String] else { break }
                var savingNewVideoNameDict = nudSavedVideoNameDict
                savingNewVideoNameDict[self.parseListId!] = video.name
                NSUserDefaults.standardUserDefaults().setObject(savingNewVideoNameDict, forKey: savedVideoNameDict)
                // update video image
                guard let nudSavedVideoImageDict:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoImageDict) as? [String: String] else { break }
                var savingNewVideoImageDict = nudSavedVideoImageDict
                savingNewVideoImageDict[self.parseListId!] = video.thumbnailUrl
                NSUserDefaults.standardUserDefaults().setObject(savingNewVideoImageDict, forKey: savedVideoImageDict)
                // update video id
                guard let nudSavedVideoIdDict:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoIdDict) as? [String: String] else { break }
                var savingNewVideoIdDict = nudSavedVideoIdDict
                savingNewVideoIdDict[self.parseListId!] = video.id
                NSUserDefaults.standardUserDefaults().setObject(savingNewVideoIdDict, forKey: savedVideoIdDict)
            }
        }
    }
    
    // MPMoviewPlayController notification methods
    func moviePlayerStateChange() {
        if let videoState:MPMoviePlaybackState = self.youtubePlayer.moviePlayer.playbackState as MPMoviePlaybackState {
            if videoState == MPMoviePlaybackState.Playing {
                self.pacMan.hidden = true
            } else {
                self.pacMan.hidden = false
            }
        }
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
    
    // MARK: Network request methods
    // Use this function to retrieve videos in playlist
    func requestPlayList(listId: String, pageToken:String?) {
        var searchParameters = [String: AnyObject]()
        searchParameters["part"] = "snippet"
        searchParameters["maxResults"] = 50
        searchParameters["playlistId"] = listId
        searchParameters["key"] = googleApiKey
        if pageToken != nil { searchParameters["pageToken"] = pageToken }
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/playlistItems?", parameters: searchParameters, encoding: ParameterEncoding.URLEncodedInURL)
            .responseJSON { response in
                if let tempString = response.result.value?["nextPageToken"] as? String where tempString != self.nextVideoPageToken { self.nextVideoPageToken = tempString; self.videoTokenCheck[tempString] = false }
                if let items:Array<Dictionary<NSObject, AnyObject>> = response.result.value?["items"] as? Array<Dictionary<NSObject, AnyObject>> { self.processVideoList(items) }
        }
    }
    
    func processVideoList(items: Array<Dictionary<NSObject, AnyObject>>) {
        for video in items {
            guard let snippet = video["snippet"] as? Dictionary<NSObject, AnyObject> else { continue }
            guard let videoTitle = snippet["title"] as? String else { continue }
            guard let ids = snippet["resourceId"] as? Dictionary<NSObject, AnyObject> else { continue }
            guard let videoId = ids["videoId"] as? String else { continue }
            guard let thumbnails = snippet["thumbnails"] as? Dictionary<NSObject, AnyObject> else { continue }
            guard let defaultThumbnail = thumbnails["default"] as? Dictionary<NSObject, AnyObject> else { continue }
            guard let defaultUrl = defaultThumbnail["url"] as? String else { continue }
            guard let heighThumbnail = thumbnails["high"] as? Dictionary<NSObject, AnyObject> else { continue }
            guard let heighUrl = heighThumbnail["url"] as? String else { continue }
            self.videoList.append(Video(id: videoId, name: videoTitle, thumbnailUrl: defaultUrl, shareImageUrl: heighUrl))
        }
        self.videoListTableView.reloadData()
    }
    
    // Use this functions to retrieve comment about the playing video
    // Use this function to get comment about video
    func getVideoCommentsData(videoId: String) {
        self.commentList.removeAll(keepCapacity: true)
        // First get the comments from self parse backend
        let commentQuery = PFQuery(className: "Comment")
        commentQuery.whereKey("videoId", equalTo: videoId)
        commentQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let comments = objects {
                    for comment in comments {
                        let newComment = Comment(name: String(comment["name"]), avatarUrl: String(comment["imageUrl"]), commentText: String(comment["text"]))
                        self.commentList.append(newComment)
                    }
                }
            } else {
                print(error)
            }
            // Second: get comments from youtube original video
            Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/commentThreads?key=\(googleApiKey)&textFormat=plainText&part=snippet&videoId=\(videoId)")
                .responseJSON { response in
                    if let tempString = response.result.value?["nextPageToken"] as? String where tempString != self.nextCommentPageToken { self.nextCommentPageToken = tempString; self.commentTokenCheck[tempString] = false }
                    if let items:Array<Dictionary<NSObject, AnyObject>> = response.result.value?["items"] as? Array<Dictionary<NSObject, AnyObject>> where items.count > 0 { self.getCommentsInfo(items) }
            }
        }
    }
    func nextComment(videoId: String, pageToken: String) {
        var searchParameters = [String: AnyObject]()
        searchParameters["textFormat"] = "plainText"
        searchParameters["part"] = "snippet"
        searchParameters["videoId"] = videoId
        searchParameters["pageToken"] = pageToken
        searchParameters["key"] = googleApiKey
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/commentThreads?", parameters: searchParameters, encoding: .URLEncodedInURL)
            .responseJSON { response in
                if let tempString = response.result.value?["nextPageToken"] as? String where tempString != self.nextCommentPageToken { self.nextCommentPageToken = tempString; self.commentTokenCheck[tempString] = false }
                if let items:Array<Dictionary<NSObject, AnyObject>> = response.result.value?["items"] as? Array<Dictionary<NSObject, AnyObject>> where items.count > 0 { self.getCommentsInfo(items) }
        }
    }
    // process the comments data from JSON
    func getCommentsInfo(items: Array<Dictionary<NSObject, AnyObject>>) {
        for comment in items {
            guard let snippet = comment["snippet"] as? Dictionary<NSObject, AnyObject> else { continue }
            guard let topLevel = snippet["topLevelComment"] as? Dictionary<NSObject, AnyObject> else { continue }
            guard let topSnippet = topLevel["snippet"] as? Dictionary<NSObject, AnyObject> else { continue }
            guard let userName = topSnippet["authorDisplayName"] as? String else { continue }
            guard let userAvatar = topSnippet["authorProfileImageUrl"] as? String else { continue }
            guard let commentText = topSnippet["textDisplay"] as? String else { continue }
            self.commentList.append(Comment(name: userName, avatarUrl: userAvatar, commentText: commentText))
        }
        self.commentListTableView.reloadData()
    }
    // End of processing comment JSON data
    // End of getting video comments
    
    // MARK: Tableview data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.videoListTableView {
            return self.videoList.count
        } else {
            return self.commentList.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.videoListTableView {
            let rowNumber = indexPath.row
            if rowNumber > 1 && rowNumber % 5 == 0 {
                return (UIScreen.mainScreen().bounds.width / 3.5) * 0.7 + 65
            } else {
                return (UIScreen.mainScreen().bounds.width / 3.5) * 0.7
            }
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == self.videoListTableView {
            if indexPath.row > 1 && indexPath.row % 5 == 0 {
                // display cell with advertise
                let cell = tableView.dequeueReusableCellWithIdentifier("AdCell") as! VideoAdListTableViewCell
                if let imageUrl:String = self.videoList[indexPath.row].shareImageUrl as String {
                    let placeholderImage = UIImage(named: "Icon-Small")
                    cell.thumbnailImageView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: placeholderImage)
                }
                if let videoTitle:String = self.videoList[indexPath.row].name as String {
                    cell.videoTitle.text = videoTitle
                }
                cell.bannerView.delegate = self
                cell.bannerView.adUnitID = googleAdUnitId
                cell.bannerView.rootViewController = self
                let request = GADRequest()
                request.testDevices = ["91b007bf71861f769b8e96af7b5922c3", kGADSimulatorID]
                cell.bannerView.loadRequest(request)
                
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                return cell
            } else {
                // display cell without ads
                let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! VideoListTableViewCell
                if let imageUrl:String = self.videoList[indexPath.row].shareImageUrl as String {
                    let placeholderImage = UIImage(named: "Icon-Small")
                    cell.thumbnailImageView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: placeholderImage)
                }
                if let videoTitle:String = self.videoList[indexPath.row].name as String {
                    cell.videoTitle.text = videoTitle
                }
                
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                return cell
            }
        } else {
            if indexPath.row > 1 && indexPath.row % 8 == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("AdCell") as! VideoDetailCommentAdCell
                if let imageUrl: String = self.commentList[indexPath.row].avatarUrl as String {
                    cell.avatarView.sd_setImageWithURL(NSURL(string: imageUrl))
                }
                if let nameText: String = self.commentList[indexPath.row].name as String {
                    cell.userNameLabel.text = nameText
                }
                if let commentText: String = self.commentList[indexPath.row].commentText as String {
                    cell.commentLabel.text = commentText
                }
                cell.bannerView.delegate = self
                cell.bannerView.adUnitID = googleAdUnitId
                cell.bannerView.rootViewController = self
                let request = GADRequest()
                request.testDevices = ["91b007bf71861f769b8e96af7b5922c3", kGADSimulatorID]
                cell.bannerView.loadRequest(request)
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! VideoDetailCommentCell
                if let imageUrl: String = self.commentList[indexPath.row].avatarUrl as String {
                    cell.avatarView.sd_setImageWithURL(NSURL(string: imageUrl))
                }
                if let nameText: String = self.commentList[indexPath.row].name as String {
                    cell.userNameLabel.text = nameText
                }
                if let commentText: String = self.commentList[indexPath.row].commentText as String {
                    cell.commentLabel.text = commentText
                }
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                return cell
            }
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.videoListTableView {
            if let selectedVideo:Video = self.videoList[indexPath.row] as Video {
                self.youtubePlayer.moviePlayer.stop()
                self.youtubePlayer.videoIdentifier = selectedVideo.id
            }
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.videoListTableView {
            if self.nextVideoPageToken != nil && indexPath.row == self.videoList.count - 10 && self.videoTokenCheck[self.nextVideoPageToken!] != true {
                self.requestPlayList(self.currentListId!, pageToken: self.nextVideoPageToken)
                self.videoTokenCheck[self.nextVideoPageToken!] = true
            }
        } else if tableView == self.commentListTableView {
            if self.nextCommentPageToken != nil && indexPath.row == self.commentList.count - 10 && self.commentTokenCheck[self.nextCommentPageToken!] != true {
                self.nextComment(self.youtubePlayer.videoIdentifier!, pageToken: self.nextCommentPageToken!)
                self.commentTokenCheck[self.nextCommentPageToken!] = true
            }
        }
    }
    
    func exitViewController() {
        self.youtubePlayer.moviePlayer.stop()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Social share methods and like tv shows
    
    func showSocialPopup() {
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("SharePopup") as! SocialShareViewController
        for video in self.videoList {
            if video.id == self.youtubePlayer.videoIdentifier {
                viewController.loadVideoInfo(video)
                viewController.shareVideo = video
            }
        }
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = true
        formSheetController.allowDismissByPanningPresentedView = true
        formSheetController.presentationController?.contentViewSize = socialViewSize
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    // Function to dismiss keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

