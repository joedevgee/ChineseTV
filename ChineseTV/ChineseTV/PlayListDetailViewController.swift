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
import Alamofire
import Async

class PlayListDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GIDSignInUIDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTopContainer()
        self.setupVideoPlayer()
        self.setupVideoList()
        self.setupCommentList()
        
        // To enable google sign in
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
        // add gesture to swipe back
        let swipeRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "exitViewController")
        swipeRecognizer.direction = .Right
        view.addGestureRecognizer(swipeRecognizer)
    }
    
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
        videoButtonUnderline.hidden = false
        
        commentListButton.backgroundColor = UIColor.clearColor()
        commentListButton.setTitle("剧透聊天", forState: .Normal)
        commentListButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        commentListButton.titleLabel?.textAlignment = .Center
        commentListButton.addTarget(self, action: "showCommentList", forControlEvents: .TouchUpInside)
        
        commentButtonUnderline.backgroundColor = UIColor.whiteColor()
        commentButtonUnderline.hidden = true
        
        videoSubContainer.addSubview(videoListButton)
        videoSubContainer.addSubview(commentListButton)
        
        videoListButton.autoPinEdgeToSuperviewEdge(.Left)
        videoListButton.autoPinEdgeToSuperviewEdge(.Top)
        videoListButton.autoPinEdgeToSuperviewEdge(.Bottom)
        videoListButton.autoMatchDimension(.Width, toDimension: .Width, ofView: videoSubContainer, withMultiplier: 0.5)
        
        commentListButton.autoPinEdgeToSuperviewEdge(.Top)
        commentListButton.autoPinEdgeToSuperviewEdge(.Right)
        commentListButton.autoPinEdgeToSuperviewEdge(.Bottom)
        commentListButton.autoPinEdge(.Left, toEdge: .Right, ofView: videoListButton)
        
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
    
    // Register as an observer of the movieplayer contentURL to automatically start playing the next video
    func changeVideo(notification: NSNotification) {
        Async.main {
            self.youtubePlayer.moviePlayer.prepareToPlay()
            self.youtubePlayer.moviePlayer.play()
            }.background {
                if self.currentListId != nil && self.videoList.count == 0 {
                    self.requestPlayList(self.currentListId!)
                }
            }.main {
                if let currentID:String = self.youtubePlayer.videoIdentifier {
                    for video in self.videoList {
                        if video.id == currentID {
                            self.videoListHeaderTitle.text = "正在播放: \(video.name)"
                        }
                    }
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
    
    func setupVideoList() {
        self.videoListTableView.delegate = self
        self.videoListTableView.dataSource = self
        self.videoListTableView.registerClass(VideoListTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.videoListTableView.separatorStyle = .None
        self.videoListTableView.backgroundColor = videoTopColor
        
        let videoListHeader:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,120))
        videoListHeader.backgroundColor = videoTopColor
        
        videoListHeaderTitle.text = ""
        videoListHeaderTitle.textColor = UIColor.whiteColor()
        videoListHeaderTitle.lineBreakMode = .ByTruncatingTail
        videoListHeaderTitle.font = UIFont.boldSystemFontOfSize(15)
        videoListHeaderTitle.textAlignment = .Left
        videoListHeaderTitle.numberOfLines = 3
        videoListHeaderTitle.sizeToFit()
        
        videoListHeader.addSubview(videoListHeaderTitle)
        
        videoListHeaderTitle.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
        videoListHeaderTitle.autoSetDimension(.Width, toSize: UIScreen.mainScreen().bounds.width*0.9, relation: .LessThanOrEqual)
        videoListHeaderTitle.autoAlignAxisToSuperviewMarginAxis(.Vertical)
        
        videoListTableView.tableHeaderView = videoListHeader
        self.view.addSubview(self.videoListTableView)
        
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
    }
    
    func setupCommentList() {
        self.commentListTableView.delegate = self
        self.commentListTableView.dataSource = self
        self.commentListTableView.registerClass(VideoDetailCommentCell.self, forCellReuseIdentifier: "Cell")
        self.commentListTableView.separatorStyle = .None
        self.commentListTableView.backgroundColor = videoTopColor
        
        let commentListHeader:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,120))
        commentListHeader.backgroundColor = videoTopColor
        
        commentListTableView.tableHeaderView = commentListHeader
        self.view.addSubview(commentListTableView)
        commentListTableView.hidden = true
        
        // Check if user signedin through google and display accordingly
        if let googleUser = GIDSignIn.sharedInstance().currentUser {
            // User signed in successfully though Google
            // Layout a comment text view to let user comment on the view
        } else {
            // The user need to sign in through google to enable comment
            // Layout a sign in button to let user sign through google
        }
        
        commentListTableView.estimatedRowHeight = 50
        commentListTableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topContainer)
        commentListTableView.autoPinEdgeToSuperviewEdge(.Left)
        commentListTableView.autoPinEdgeToSuperviewEdge(.Right)
        commentListTableView.autoPinEdgeToSuperviewEdge(.Bottom)
        
    }
    
    func showCommentList() {
        self.getVideoCommentsData(self.youtubePlayer.videoIdentifier!)
        self.commentButtonUnderline.hidden = false
        self.videoButtonUnderline.hidden = true
        self.videoListTableView.hidden = true
        self.commentListTableView.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Use this function to retrieve videos in playlist
    func requestPlayList(listId: String) {
        let resultNumber:Int = 50
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(resultNumber)&playlistId=\(listId)&key=\(googleApiKey)")
            .responseJSON { response in
                if let JSON = response.result.value {
                    if let items = JSON["items"] as? Array<AnyObject> {
                        self.processVideoList(items)
                    }
                }
        }
    }
    
    func processVideoList(items: Array<AnyObject>) {
        for video in items {
            if let videoDict:Dictionary<NSObject, AnyObject> = video as? Dictionary<NSObject, AnyObject> {
                if let snippetDict:Dictionary<NSObject, AnyObject> = videoDict["snippet"] as? Dictionary<NSObject, AnyObject> {
                    if let resourceDict:Dictionary<NSObject, AnyObject> = snippetDict["resourceId"] as? Dictionary<NSObject, AnyObject> {
                        if let thumbnailsDict:Dictionary<NSObject, AnyObject> = snippetDict["thumbnails"] as? Dictionary<NSObject, AnyObject> {
                            if let videoId:String = resourceDict["videoId"] as? String {
                                if let videoTitle: String = snippetDict["title"] as? String {
                                    if let imageUrl: String = thumbnailsDict["default"]!["url"] as? String {
                                        let video = Video(id: videoId, name: videoTitle, thumbnailUrl: imageUrl)
                                        if let currentID:String = self.youtubePlayer.videoIdentifier {
                                            if currentID == video.id {
                                                self.videoListHeaderTitle.text = "正在播放: \(video.name)"
                                            }
                                        }
                                        self.videoList.append(video)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        self.videoListTableView.reloadData()
    }
    
    // Use this functions to retrieve comment about the playing video
    // Use this function to get comment about video
    func getVideoCommentsData(videoId: String) {
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/commentThreads?key=\(googleApiKey)&textFormat=plainText&part=snippet&videoId=\(videoId)")
            .responseJSON { response in
                if let JSON = response.result.value {
                    if let items: AnyObject = JSON["items"] as? Array<AnyObject> {
                        if items.count > 0 {
                            self.getCommentsInfo(items as! Array<AnyObject>)
                        } else {
                            print("No comments returned")
                        }
                    }
                }
        }
    }
    // process the comments data from JSON
    func getCommentsInfo(items: Array<AnyObject>) {
        self.commentList.removeAll(keepCapacity: true)
        for item in items {
            if let itemDict: Dictionary<NSObject, AnyObject> = item as? Dictionary<NSObject, AnyObject> {
                if let topSnippet: Dictionary<NSObject, AnyObject> = itemDict["snippet"] as? Dictionary<NSObject, AnyObject> {
                    if let topLevel: Dictionary<NSObject, AnyObject> = topSnippet["topLevelComment"] as? Dictionary<NSObject, AnyObject> {
                        if let commentSnippet: Dictionary<NSObject, AnyObject> = topLevel["snippet"] as? Dictionary<NSObject, AnyObject> {
                            let comment = Comment(name: String(commentSnippet["authorDisplayName"]!), avatarUrl: String(commentSnippet["authorProfileImageUrl"]!), commentText: String(commentSnippet["textDisplay"]!))
                            self.commentList.append(comment)
                        }
                    }
                }
            }
        }
        self.commentListTableView.reloadData()
    }
    // End of processing comment JSON data
    // End of getting video comments
    
    // Tableview data source
    
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
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
