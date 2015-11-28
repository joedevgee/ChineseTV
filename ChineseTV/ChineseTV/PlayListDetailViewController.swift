//
//  PlayListDetailViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/11/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

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
import TTGSnackbar

class PlayListDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FBSDKLoginButtonDelegate, UITextViewDelegate {
    
    var currentListId:String?
    
    var videoList: [Video] = []
    var commentList: [Comment] = []
    
    var topContainer:UIView = UIView.newAutoLayoutView()
    var videoContainer:UIView = UIView.newAutoLayoutView()
    var youtubePlayer = XCDYouTubeVideoPlayerViewController()
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
    var commentTextView:UITextView = UITextView.newAutoLayoutView()
    var sendCommentButton:UIButton = UIButton.newAutoLayoutView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTopContainer()
        self.setupVideoPlayer()
        self.setupVideoList()
        self.setupCommentList()
        
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
        } else {
            self.fbProfileView.hidden = true
            self.commentTextView.hidden = true
            self.sendCommentButton.hidden = true
            self.fbLoginButton.hidden = false
            self.loginInfoLabel.hidden = false
        }
        // Observe for profile change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeProfile", name: FBSDKProfileDidChangeNotification, object: nil)
        
    }
    
    // MARK: Setup the UI
    func setupTopContainer() {
        
        topContainer.backgroundColor = UIColor.clearColor()
        self.view.addSubview(topContainer)
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
        
        commentListButton.autoPinEdgeToSuperviewEdge(.Left)
        commentListButton.autoPinEdgeToSuperviewEdge(.Top)
        commentListButton.autoPinEdgeToSuperviewEdge(.Bottom)
        commentListButton.autoMatchDimension(.Width, toDimension: .Width, ofView: videoSubContainer, withMultiplier: 0.5)
        
        videoListButton.autoPinEdgeToSuperviewEdge(.Top)
        videoListButton.autoPinEdgeToSuperviewEdge(.Right)
        videoListButton.autoPinEdgeToSuperviewEdge(.Bottom)
        videoListButton.autoPinEdge(.Left, toEdge: .Right, ofView: commentListButton)
        
        videoListButton.addSubview(videoButtonUnderline)
        commentListButton.addSubview(commentButtonUnderline)
        
        videoButtonUnderline.autoSetDimension(.Height, toSize: 2)
        videoButtonUnderline.autoPinEdgeToSuperviewEdge(.Bottom)
        videoButtonUnderline.autoPinEdgeToSuperviewEdge(.Leading)
        videoButtonUnderline.autoPinEdgeToSuperviewEdge(.Trailing)
        
        commentButtonUnderline.autoSetDimension(.Height, toSize: 2)
        commentButtonUnderline.autoPinEdgeToSuperviewEdge(.Leading)
        commentButtonUnderline.autoPinEdgeToSuperviewEdge(.Trailing)
        commentButtonUnderline.autoPinEdgeToSuperviewEdge(.Bottom)
    }
    
    func setupVideoPlayer() {
        // Use below notifications to detect when user entered or exited full-screen mode
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterFullScreen", name: MPMoviePlayerWillEnterFullscreenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willExitFullScreen", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        // Remove this notification so player doesn't dismiss automatically at the end of video
        NSNotificationCenter.defaultCenter().removeObserver(youtubePlayer, name: MPMoviePlayerPlaybackDidFinishNotification, object: youtubePlayer.moviePlayer)
        // Add observer to handle changing video
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("changeVideo:"), name: XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification, object: nil)
        
        youtubePlayer.presentInView(self.videoContainer)
        youtubePlayer.moviePlayer.cancelAllThumbnailImageRequests()
        youtubePlayer.moviePlayer.shouldAutoplay = true
        youtubePlayer.moviePlayer.scalingMode = .AspectFill
        
        let closeButton = UIButton()
        closeButton.addTarget(self, action: Selector("exitViewController"), forControlEvents: .TouchUpInside)
        let closeImage = UIImage(named:"ic_clear")?.imageWithRenderingMode(
            UIImageRenderingMode.AlwaysTemplate)
        closeButton.tintColor = UIColor.whiteColor()
        closeButton.setImage(closeImage, forState: .Normal)
        youtubePlayer.moviePlayer.view.addSubview(closeButton)
        
        closeButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
        closeButton.autoPinEdgeToSuperviewEdge(.Left)
    }
    
    func setupVideoList() {
        self.videoListTableView.delegate = self
        self.videoListTableView.dataSource = self
        self.videoListTableView.registerClass(VideoListTableViewCell.self, forCellReuseIdentifier: "Cell")
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
        
        videoListHeaderTitle.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
        videoListHeaderTitle.autoSetDimension(.Width, toSize: UIScreen.mainScreen().bounds.width*0.9, relation: .LessThanOrEqual)
        videoListHeaderTitle.autoAlignAxisToSuperviewMarginAxis(.Vertical)
        
        videoShareButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 10, relation: .LessThanOrEqual)
        videoShareButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5, relation: .LessThanOrEqual)
        
        videoListTableView.tableHeaderView = videoListHeader
        self.view.addSubview(self.videoListTableView)
        videoListTableView.hidden = true
        
        videoListTableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topContainer)
        videoListTableView.autoPinEdgeToSuperviewEdge(.Left)
        videoListTableView.autoPinEdgeToSuperviewEdge(.Right)
        videoListTableView.autoPinEdgeToSuperviewEdge(.Bottom)
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
        self.commentListTableView.separatorStyle = .None
        self.commentListTableView.backgroundColor = videoTopColor
        
        // add gesture to dismiss keyboard
        let tapDismiss:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        commentListTableView.addGestureRecognizer(tapDismiss)
        
        let commentListHeader:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,120))
        commentListHeader.backgroundColor = videoTopColor
        
        commentListTableView.tableHeaderView = commentListHeader
        self.view.addSubview(commentListTableView)
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
        
        commentListHeader.addSubview(fbProfileView)
        commentListHeader.addSubview(fbLoginButton)
        commentListHeader.addSubview(loginInfoLabel)
        commentListHeader.addSubview(commentTextView)
        commentListHeader.addSubview(sendCommentButton)
        commentListHeader.addSubview(commentShareButton)
        
        fbProfileView.autoSetDimensionsToSize(CGSize(width: 30, height: 30))
        fbProfileView.autoPinEdgeToSuperviewEdge(.Top, withInset: 8, relation: .LessThanOrEqual)
        fbProfileView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 5, relation: .LessThanOrEqual)
        
        commentShareButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 10, relation: .LessThanOrEqual)
        commentShareButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5, relation: .LessThanOrEqual)
        
        sendCommentButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
        sendCommentButton.autoAlignAxis(.Vertical, toSameAxisOfView: commentShareButton)
        
        loginInfoLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 20, relation: .GreaterThanOrEqual)
        loginInfoLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20, relation: .GreaterThanOrEqual)
        
        fbLoginButton.autoAlignAxis(.Horizontal, toSameAxisOfView: loginInfoLabel)
        fbLoginButton.autoPinEdge(.Left, toEdge: .Right, ofView: loginInfoLabel, withOffset: 10, relation: .GreaterThanOrEqual)
        
        commentTextView.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
        commentTextView.autoPinEdge(.Left, toEdge: .Right, ofView: fbProfileView, withOffset: 5)
        commentTextView.autoPinEdge(.Right, toEdge: .Left, ofView: sendCommentButton, withOffset: -5)
        commentTextView.autoPinEdge(.Bottom, toEdge: .Top, ofView: commentShareButton, withOffset: -2)
        
        commentListTableView.estimatedRowHeight = 50
        commentListTableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topContainer)
        commentListTableView.autoPinEdgeToSuperviewEdge(.Left)
        commentListTableView.autoPinEdgeToSuperviewEdge(.Right)
        commentListTableView.autoPinEdgeToSuperviewEdge(.Bottom)
        
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
            var commenterName:String = ""
            var commenterImageUrl:String = ""
            // Retrieve info from facebook
            if FBSDKAccessToken.currentAccessToken() != nil {
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name,id,picture"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                    if error != nil {
                        print("Graph request failed with error: \(error)")
                    } else {
                        if let name:NSString =  result.valueForKey("name") as? NSString {
                            commenterName = name as String
                        }
                        if let imageUrl:NSString = result.valueForKey("picture")!.valueForKey("data")?.valueForKey("url") as? NSString {
                            commenterImageUrl = imageUrl as String
                        }
                        // Save new comment to Parse
                        let savingComment = PFObject(className: "Comment")
                        savingComment["text"] = sendingComment
                        savingComment["name"] = commenterName
                        savingComment["imageUrl"] = commenterImageUrl
                        savingComment["videoId"] = self.youtubePlayer.videoIdentifier
                        // Create a placeholder Comment item to display when user successfully posted new comment
                        let newComment = Comment(name: commenterName, avatarUrl: commenterImageUrl, commentText: sendingComment)
                        savingComment.saveInBackgroundWithBlock {
                            (success:Bool, error:NSError?) -> Void in
                            if success {
                                let successBar = TTGSnackbar.init(message: "您的回复已成功发送", duration: .Middle)
                                successBar.show()
                                self.commentList.insert(newComment, atIndex: 0)
                                self.commentListTableView.reloadData()
                            }
                        }
                    }
                })
            }
            // End of retrieving info from facebook graph
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
        }
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out of facebook")
    }
    
    // Update profile picture
    func changeProfile() {
        self.fbProfileView.profileID = FBSDKAccessToken.currentAccessToken().userID
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
    
    // MARK: XCDYouTubeKit delegate methods
    // Register as an observer of the movieplayer contentURL to automatically start playing the next video
    func changeVideo(notification: NSNotification) {
        Async.main {
            self.youtubePlayer.moviePlayer.prepareToPlay()
            self.youtubePlayer.moviePlayer.play()
            }.background {
                self.getVideoCommentsData(self.youtubePlayer.videoIdentifier!)
                // Check if the current video is in a saved playlist
                if let userList = NSUserDefaults.standardUserDefaults().arrayForKey("savedPlaylist") as? [String] where userList.contains(self.currentListId!) {
                    // User has saved this list
                    // Update the saved playlist with current progress-- current video
                    for video in self.videoList {
                        if video.id == self.youtubePlayer.videoIdentifier {
                            // update the progress name
                            if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressName") as? [String:String] {
                                var newDict = tempDict
                                newDict[self.currentListId!] = video.name
                                NSUserDefaults.standardUserDefaults().setObject(newDict, forKey: "playlistProgressName")
                            }
                            // update the progress image url
                            if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressImageUrl") as? [String:String] {
                                var newDict = tempDict
                                newDict[self.currentListId!] = video.thumbnailUrl
                                NSUserDefaults.standardUserDefaults().setObject(newDict, forKey: "playlistProgressImageUrl")
                            }
                            // update the progress id
                            if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressId") as? [String:String] {
                                var newDict = tempDict
                                newDict[self.currentListId!] = video.id
                                NSUserDefaults.standardUserDefaults().setObject(newDict, forKey: "playlistProgressId")
                            }
                        }
                    }
                    // End of updateing playlist info
                } else {
                    // The video is not in a saved playlist by the user
                    // Do nothing
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
    func requestPlayList(listId: String) {
        let resultNumber:Int = 50
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(resultNumber)&playlistId=\(listId)&key=\(googleApiKey)")
            .responseJSON { response in if let items:Array<Dictionary<NSObject, AnyObject>> = response.result.value?["items"] as? Array<Dictionary<NSObject, AnyObject>> { self.processVideoList(items) }
        }
    }
    
    func processVideoList(items: Array<Dictionary<NSObject, AnyObject>>) {
        for video in items {
            guard let videoId = video["snippet"]!["resourceId"]!!["videoId"] as? String else { print("getting video id failed");break }
            guard let videoTitle = video["snippet"]!["title"] as? String else { print("getting video title failed");break }
            guard let videoThumbnail = video["snippet"]!["thumbnails"]!!["default"]!!["url"] as? String else { print("getting video thumbnail failed");break }
            guard let videoShareImage = video["snippet"]!["thumbnails"]!!["high"]!!["url"] as? String else { print("getting video image for share failed");break }
            self.videoList.append(Video(id: videoId, name: videoTitle, thumbnailUrl: videoThumbnail, shareImageUrl: videoShareImage))
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
                .responseJSON { response in if let items:Array<Dictionary<NSObject, AnyObject>> = response.result.value?["items"] as? Array<Dictionary<NSObject, AnyObject>> where items.count > 0 { self.getCommentsInfo(items) }
            }
        }
    }
    // process the comments data from JSON
    func getCommentsInfo(items: Array<Dictionary<NSObject, AnyObject>>) {
        for comment in items {
            guard let authorName = comment["snippet"]!["topLevelComment"]!!["snippet"]!!["authorDisplayName"] as? String else { print("getting user name failed"); break }
            guard let userAvatar = comment["snippet"]!["topLevelComment"]!!["snippet"]!!["authorProfileImageUrl"] as? String else { print("getting user avatar failed"); break }
            guard let commentText = comment["snippet"]!["topLevelComment"]!!["snippet"]!!["textDisplay"] as? String else { print("getting user comment text failed"); break }
            self.commentList.append(Comment(name: authorName, avatarUrl: userAvatar, commentText: commentText))
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
            return (UIScreen.mainScreen().bounds.width / 3.5) * 0.7
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == self.videoListTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! VideoListTableViewCell
            if let imageUrl:String = self.videoList[indexPath.row].thumbnailUrl as String {
                cell.thumbnailImageView.sd_setImageWithURL(NSURL(string: imageUrl))
            }
            if let videoTitle:String = self.videoList[indexPath.row].name as String {
                cell.videoTitle.text = videoTitle
            }
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! VideoDetailCommentCell
            if let imageUrl: String = self.commentList[indexPath.row].avatarUrl as String {
                cell.avatarView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: UIImage(named: "category.jpg"))
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.videoListTableView {
            print(indexPath.row)
            if let selectedVideo:Video = self.videoList[indexPath.row] as Video {
                self.youtubePlayer.moviePlayer.stop()
                self.youtubePlayer.videoIdentifier = selectedVideo.id
            }
        }
    }
    
    func exitViewController() {
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
