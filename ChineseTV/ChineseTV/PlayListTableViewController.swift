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
        if let favList = NSUserDefaults.standardUserDefaults().arrayForKey("savedPlaylist") as? [String] where favList.contains(self.currentListId!) {
            navCancelButton()
        } else {
            navAddButton()
        }
    }
    func navAddButton() {
        // Add a navi right button to let people add playlist
        let addImage = UIImage(named: "ic_playlist_add")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let addButton = UIBarButtonItem(image: addImage, style: .Plain, target: self, action: "addPlaylist")
        navigationItem.rightBarButtonItem = addButton
    }
    func navCancelButton() {
        // Add a navi right button to let people delete added playlist
        let savedImage = UIImage(named: "ic_playlist_add_check")?.imageWithRenderingMode(.AlwaysTemplate)
        let savedButton = UIBarButtonItem(image: savedImage, style: .Plain, target: self, action: "deleteList")
        navigationItem.rightBarButtonItem = savedButton
    }
    
    // MARK: Let user add or delete current playlist to their personal list
    func addPlaylist() {
        // Create a playlist item based on current playlist id
        if let tempArray = NSUserDefaults.standardUserDefaults().arrayForKey("savedPlaylist") as? [String] {
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
            self.navCancelButton()
            let successBar = TTGSnackbar.init(message: "您已成功收藏该节目", duration: TTGSnackbarDuration.Middle)
            successBar.show()
        }
    }
    
    // let user delete current list
    func deleteList() {
        if let tempArray = NSUserDefaults.standardUserDefaults().arrayForKey("savedPlaylist") as? [String] {
            self.savedPlaylist = tempArray
        }
        if self.savedPlaylist.contains(self.currentListId!) {
            // alert user if wants to delete list from saved list
            let snackbar = TTGSnackbar.init(message: "从收藏列表删除该节目？", duration: TTGSnackbarDuration.Middle, actionText: "确定")
                { (snackbar) -> Void in
                    // Officially delete currentlist from nsuserdefaults
                    if let deletingIndex = self.savedPlaylist.indexOf(self.currentListId!) {
                        // remove list id from saved playlist arrays
                        self.savedPlaylist.removeAtIndex(deletingIndex)
                        NSUserDefaults.standardUserDefaults().setObject(self.savedPlaylist, forKey: "savedPlaylist")
                        // remove list name from saved playlist name dictionary
                        if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistName") as? [String: String] {
                            self.listName = tempDict
                            self.listName.removeValueForKey(self.currentListId!)
                            NSUserDefaults.standardUserDefaults().setObject(self.listName, forKey: "playlistName")
                        }
                        // remove playlist progress name
                        if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressName") as? [String: String] {
                            self.listProgressName = tempDict
                            self.listProgressName.removeValueForKey(self.currentListId!)
                            NSUserDefaults.standardUserDefaults().setObject(self.listProgressName, forKey: "playlistProgressName")
                        }
                        // remove playlist progress image url
                        if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressImageUrl") as? [String: String] {
                            self.listProgressImageUrl = tempDict
                            self.listProgressImageUrl.removeValueForKey(self.currentListId!)
                            NSUserDefaults.standardUserDefaults().setObject(self.listProgressImageUrl, forKey: "playlistProgressImageUrl")
                        }
                        // remove playlist progress video id
                        if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressId") as? [String: String] {
                            self.listProgressId = tempDict
                            self.listProgressId.removeValueForKey(self.currentListId!)
                            NSUserDefaults.standardUserDefaults().setObject(self.listProgressId, forKey: "playlistProgressId")
                        }
                        
                        self.navAddButton()
                    }
            }
            snackbar.show()
        } else {
            // current list is not saved
            // change to nav right button to let user add current list
            self.navAddButton()
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
