//
//  VideoDetailTableViewController.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/18/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import FBSDKShareKit
import XCDYouTubeKit
import Alamofire
import SDWebImage

class VideoDetailTableViewController: UITableViewController {
    
    let headerHeight:CGFloat = UIScreen.mainScreen().bounds.size.width*0.70
    // Search query for Tweets matching the right hashtags and containing an attached poem picture.
    var youtubeID:String?
    var channelTitle:String?
    var channelImageUrl:String?
    var commentsList: [Comment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(VideoDetailCommentCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: 0)
        if let videoId = self.youtubeID {
            self.getVideoCommentsData(videoId)
        }
    }
    
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
                            self.commentsList.append(comment)
                        }
                    }
                }
            }
        }
        tableView.reloadData()
    }
    // End of processing comment JSON data
    // End of getting video comments

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("Header") as! VideoDetailHeader
        
        if youtubeID != nil {
            let youtubePlayer = XCDYouTubeVideoPlayerViewController.init(videoIdentifier: youtubeID!)
            youtubePlayer.presentInView(headerCell.playerContainer)
            youtubePlayer.moviePlayer.play()
            // Add a close button to the player view
            let closeButton = UIButton()
            closeButton.addTarget(self, action: Selector("exitViewController"), forControlEvents: .TouchUpInside)
            let closeImage = UIImage(named:"ic_clear")?.imageWithRenderingMode(
                UIImageRenderingMode.AlwaysTemplate)
            closeButton.tintColor = UIColor.whiteColor()
            closeButton.setImage(closeImage, forState: .Normal)
            youtubePlayer.moviePlayer.view.addSubview(closeButton)
            youtubePlayer.moviePlayer.view.backgroundColor = themeBackgroundColor
            
            closeButton.autoPinEdgeToSuperviewEdge(.Top)
            closeButton.autoPinEdgeToSuperviewEdge(.Left)
        }
        
        if channelTitle != nil {
            headerCell.channelTitle.text = "Source: " + channelTitle!
        }
        
        // Add social share
        // Facebook
        let facebookTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("shareToFacebook"))
        headerCell.facebookLabel.userInteractionEnabled = true
        headerCell.facebookLabel.addGestureRecognizer(facebookTap)
        
        headerCell.setNeedsUpdateConstraints()
        headerCell.updateConstraintsIfNeeded()
        return headerCell
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! VideoDetailCommentCell
        if let imageUrl: String = self.commentsList[indexPath.row].avatarUrl as String {
            cell.avatarView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: UIImage(named: "category.jpg"))
        }
        if let nameText: String = self.commentsList[indexPath.row].name as String {
            cell.userNameLabel.text = nameText
        }
        if let commentText: String = self.commentsList[indexPath.row].commentText as String {
            cell.commentLabel.text = commentText
        }
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    // Social share settings
    func shareToFacebook() {
        print("Facebook tapped")
        let shareContent:FBSDKShareLinkContent = FBSDKShareLinkContent()
        shareContent.contentDescription = "This is a test share"
        shareContent.contentTitle = "Content title"
        shareContent.contentURL = NSURL(string: "https://www.qq.com")
        shareContent.imageURL = NSURL(string: "http://s11.postimg.org/m35ftbsur/IMG_0019.png")
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogMode.FeedWeb
        dialog.shareContent = shareContent
        dialog.fromViewController = self
        dialog.show()
    }
    // End of social share settings
    
    func exitViewController() {
        navigationController?.popViewControllerAnimated(true)
    }
}

class Comment {
    
    var name: String
    var avatarUrl: String
    var commentText: String
    
    init(name: String, avatarUrl: String, commentText: String) {
        self.name = name
        self.avatarUrl = avatarUrl
        self.commentText = commentText
    }
    
}
