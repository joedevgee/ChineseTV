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

class PlayListDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var playingVideoId:String?
    
    var videoList: [Video] = []
    var commentList: [Comment] = []
    
    var topContainer:UIView = UIView.newAutoLayoutView()
    var videoContainer:UIView = UIView.newAutoLayoutView()
    var youtubePlayer = XCDYouTubeVideoPlayerViewController()
    var videoSubContainer:UIView = UIView.newAutoLayoutView()
    
    var videoListButton:UIButton = UIButton.newAutoLayoutView()
    var commentListButton:UIButton = UIButton.newAutoLayoutView()
    
    var videoListTableView:UITableView = UITableView.newAutoLayoutView()
    var videoListHeaderTitle:UILabel = UILabel.newAutoLayoutView()
    var commentListTableView:UITableView = UITableView.newAutoLayoutView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTopContainer()
        self.setupVideoPlayer()
        self.setupVideoList()
        self.setupCommentList()
        
        // add gesture to swipe back
        let swipeRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "exitViewController")
        swipeRecognizer.direction = .Right
        view.addGestureRecognizer(swipeRecognizer)
    }
    
    func setupTopContainer() {
        
        topContainer.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(topContainer)
        topContainer.autoPinToTopLayoutGuideOfViewController(self, withInset: 0)
        topContainer.autoPinEdgeToSuperviewEdge(.Left)
        topContainer.autoPinEdgeToSuperviewEdge(.Right)
        topContainer.autoSetDimension(.Height, toSize: UIScreen.mainScreen().bounds.width*0.8)
        
        videoContainer.backgroundColor = UIColor.blackColor()
        self.topContainer.addSubview(videoContainer)
        videoContainer.autoSetDimension(.Height, toSize: UIScreen.mainScreen().bounds.width*0.75)
        videoContainer.autoPinEdgeToSuperviewEdge(.Left)
        videoContainer.autoPinEdgeToSuperviewEdge(.Right)
        videoContainer.autoPinEdgeToSuperviewEdge(.Top, withInset: -35)
        
        videoSubContainer.backgroundColor = UIColor.whiteColor()
        self.topContainer.addSubview(videoSubContainer)
        videoSubContainer.autoPinEdgeToSuperviewEdge(.Left)
        videoSubContainer.autoPinEdgeToSuperviewEdge(.Right)
        videoSubContainer.autoPinEdgeToSuperviewEdge(.Bottom)
        videoSubContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: videoContainer)
        
        videoListButton.setTitle("Show Video", forState: .Normal)
        videoListButton.backgroundColor = UIColor.yellowColor()
        videoListButton.addTarget(self, action: "showVideoList", forControlEvents: .TouchUpInside)
        
        commentListButton.setTitle("Show Comment", forState: .Normal)
        commentListButton.backgroundColor = UIColor.blueColor()
        commentListButton.addTarget(self, action: "showCommentList", forControlEvents: .TouchUpInside)
        
        videoSubContainer.addSubview(videoListButton)
        videoSubContainer.addSubview(commentListButton)
        
        videoListButton.autoSetDimensionsToSize(CGSize(width: 20, height: 20))
        videoListButton.autoAlignAxisToSuperviewAxis(.Horizontal)
        videoListButton.autoPinEdgeToSuperviewEdge(.Left)
        
        commentListButton.autoSetDimensionsToSize(CGSize(width: 20, height: 20))
        commentListButton.autoAlignAxisToSuperviewAxis(.Horizontal)
        commentListButton.autoPinEdgeToSuperviewEdge(.Right)
        
    }
    
    func setupVideoPlayer() {
        // Use below notifications to detect when user entered or exited full-screen mode
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterFullScreen", name: MPMoviePlayerWillEnterFullscreenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willExitFullScreen", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)

        // Remove this notification so player doesn't dismiss automatically at the end of video
        NSNotificationCenter.defaultCenter().removeObserver(youtubePlayer, name: MPMoviePlayerPlaybackDidFinishNotification, object: youtubePlayer.moviePlayer)

        youtubePlayer.moviePlayer.cancelAllThumbnailImageRequests()
        youtubePlayer.moviePlayer.shouldAutoplay = true

        let closeButton = UIButton()
        closeButton.addTarget(self, action: Selector("exitViewController"), forControlEvents: .TouchUpInside)
        let closeImage = UIImage(named:"ic_clear")?.imageWithRenderingMode(
            UIImageRenderingMode.AlwaysTemplate)
        closeButton.tintColor = UIColor.whiteColor()
        closeButton.setImage(closeImage, forState: .Normal)
        youtubePlayer.moviePlayer.view.addSubview(closeButton)

        closeButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 35)
        closeButton.autoPinEdgeToSuperviewEdge(.Left)
    }
    
    // Register as an observer of the movieplayer contentURL to automatically start playing the next video
    
    func playVideo(videoId: String) {
        youtubePlayer.videoIdentifier = videoId
        youtubePlayer.presentInView(videoContainer)
        self.playingVideoId = videoId
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
        
        let videoListHeader:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,120))
        videoListHeader.backgroundColor = UIColor.whiteColor()
        
        videoListHeaderTitle.text = ""
        videoListHeaderTitle.lineBreakMode = .ByTruncatingTail
        videoListHeaderTitle.font = UIFont.boldSystemFontOfSize(15)
        videoListHeaderTitle.textAlignment = .Left
        videoListHeaderTitle.numberOfLines = 3
        videoListHeaderTitle.sizeToFit()
        
        videoListHeader.addSubview(videoListHeaderTitle)
        
        videoListHeaderTitle.autoPinEdgeToSuperviewEdge(.Top)
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
        self.commentListTableView.hidden = true
    }
    
    func setupCommentList() {
        self.commentListTableView.delegate = self
        self.commentListTableView.dataSource = self
        self.commentListTableView.registerClass(VideoDetailCommentCell.self, forCellReuseIdentifier: "Cell")
        
        self.view.addSubview(commentListTableView)
        commentListTableView.hidden = true
        
        commentListTableView.estimatedRowHeight = 50
        commentListTableView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topContainer)
        commentListTableView.autoPinEdgeToSuperviewEdge(.Left)
        commentListTableView.autoPinEdgeToSuperviewEdge(.Right)
        commentListTableView.autoPinEdgeToSuperviewEdge(.Bottom)
        
    }
    
    func showCommentList() {
        self.getVideoCommentsData(self.playingVideoId!)
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
                                        if video.id == self.playingVideoId {
                                            self.videoListHeaderTitle.text = "正在播放： \(video.name)"
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
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/commentThreads?key=\(googleApiKey)&textFormat=plainText&part=snippet&videoId=\(videoId)&maxResults=20")
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
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.videoListTableView {
            print(indexPath.row)
        }
    }
    
    func exitViewController() {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
