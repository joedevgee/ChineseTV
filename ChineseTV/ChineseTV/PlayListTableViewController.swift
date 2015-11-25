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
import TTGSnackbar

class PlayListTableViewController: UITableViewController {
    
    var currentListId:String?
    var currentListName:String?
    var videoList: [Video] = []
    var savedPlaylist: [String] = []
    var listProgressName = [String: String]()
    var listProgressImageUrl = [String: String]()
    var listProgressId = [String: String]()
    var listName = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true
        tableView.separatorStyle = .None
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let favList = NSUserDefaults.standardUserDefaults().arrayForKey("savedPlaylist") as? [String] where self.currentListId != nil {
            if favList.contains(self.currentListId!) {
                // Current list is already saved by the user
                // Add an option for the user to delete this list from saved list
                self.navCancelButton()
            } else {
                // Current list has not been saved by user
                // Add an option for the user to save this list
                self.navAddButton()
            }
        }
    }
    func navAddButton() {
        // Add a navi right button to let people add playlist
        let addImage = UIImage(named: "ic_playlist_add")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let addButton = UIBarButtonItem(image: addImage, style: .Plain, target: self, action: "addPlaylist")
        navigationItem.rightBarButtonItem = addButton
    }
    func navCancelButton() {
        
    }
    
    // MARK: Let user add current playlist to their personal list
    func addPlaylist() {
        // Create a playlist item based on current playlist id
        if let tempArray = NSUserDefaults.standardUserDefaults().arrayForKey("savedPlaylist") as? [String] {
            print("Got list array from userdefault")
            self.savedPlaylist = tempArray
        }
        if self.savedPlaylist.contains(self.currentListId!) {
            print("This list is already saved")
        } else {
            print("Adding list to user default")
            savedPlaylist.append(self.currentListId!)
            NSUserDefaults.standardUserDefaults().setObject(savedPlaylist, forKey: "savedPlaylist")
            print("Successfully updated savedPlaylist")
            // Update the saved list with current progress
            // Save video name
            if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressName") as? [String: String] {
                self.listProgressName = tempDict
            }
            self.listProgressName[self.currentListId!] = self.videoList[0].name
            NSUserDefaults.standardUserDefaults().setObject(self.listProgressName, forKey: "playlistProgressName")
            // Save video thumbnail url
            if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressImageUrl") as? [String: String] {
                self.listProgressImageUrl = tempDict
            }
            self.listProgressImageUrl[self.currentListId!] = self.videoList[0].thumbnailUrl
            NSUserDefaults.standardUserDefaults().setObject(self.listProgressImageUrl, forKey: "playlistProgressImageUrl")
            // Save video id
            if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressId") as? [String: String] {
                self.listProgressId = tempDict
            }
            self.listProgressId[self.currentListId!] = self.videoList[0].id
            NSUserDefaults.standardUserDefaults().setObject(self.listProgressId, forKey: "playlistProgressId")
            
            // Save the list name
            if let tempNameDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistName") as? [String: String] {
                self.listName = tempNameDict
            }
            self.listName[self.currentListId!] = self.currentListName!
            NSUserDefaults.standardUserDefaults().setObject(self.listName, forKey: "playlistName")
            let successBar = TTGSnackbar.init(message: "您已成功收藏该节目", duration: TTGSnackbarDuration.Middle)
            successBar.show()
        }
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
            if self.currentListId != nil {
                destVC.currentListId = self.currentListId!
            } else {
                print("list id is nil")
            }
            if self.videoList.count > 0 {
                destVC.videoList = self.videoList
            } else {
                destVC.requestPlayList(self.currentListId!)
            }
            if let selectedVideo = sender as? Video {
                destVC.youtubePlayer.videoIdentifier = selectedVideo.id
                destVC.videoListHeaderTitle.text = "正在播放： " + selectedVideo.name
            } else if let data:Dictionary<String, String> = sender as? Dictionary<String, String> {
                destVC.youtubePlayer.videoIdentifier = data["videoId"]!
                destVC.videoListHeaderTitle.text = "正在播放： " + data["videoName"]!
            }
        }
    }

}
