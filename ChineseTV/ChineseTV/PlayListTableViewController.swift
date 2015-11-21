//
//  PlayListTableViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/20/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import Async


class PlayListTableViewController: UITableViewController {
    
    var currentListId:String?
    var videoList: [Video] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.separatorStyle = .None
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (UIScreen.mainScreen().bounds.width / 3.5) * 0.7
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.videoList.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedVideo:Video = self.videoList[indexPath.row] {
            performSegueWithIdentifier("showVideo", sender: selectedVideo)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! VideoListTableViewCell
        cell.contentView.backgroundColor = UIColor.whiteColor()
        if let imageUrl:String = self.videoList[indexPath.row].thumbnailUrl as String {
            cell.thumbnailImageView.sd_setImageWithURL(NSURL(string: imageUrl))
        }
        if let videoTitle:String = self.videoList[indexPath.row].name as String {
            cell.videoTitle.text = videoTitle
            cell.videoTitle.textColor = UIColor.blackColor()
        }
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    // MARK: Network request methods
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
                                        var shareImageUrl:String?
                                        if let maxUrl = thumbnailsDict["maxres"]?["url"] as? String {
                                            shareImageUrl = maxUrl
                                        } else if let stdUrl = thumbnailsDict["standard"] as? String {
                                            shareImageUrl = stdUrl
                                        } else if let highUrl = thumbnailsDict["high"] as? String {
                                            shareImageUrl = highUrl
                                        } else if let mediumUrl = thumbnailsDict["medium"] as? String {
                                            shareImageUrl = mediumUrl
                                        } else {
                                            shareImageUrl = imageUrl
                                        }
                                        let video = Video(id: videoId, name: videoTitle, thumbnailUrl: imageUrl, shareImageUrl: shareImageUrl!)
                                        self.videoList.append(video)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        tableView.reloadData()
    }

    //MARK: Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVideo" {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            let destVC = segue.destinationViewController as! PlayListDetailViewController
            if let selectedVideo = sender as? Video {
                destVC.youtubePlayer.videoIdentifier = selectedVideo.id
                destVC.videoList = self.videoList
                destVC.videoListHeaderTitle.text = "正在播放： " + selectedVideo.name
                if self.currentListId != nil {
                    destVC.currentListId = self.currentListId!
                }
            }
        }
    }

}
