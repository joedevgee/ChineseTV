//
//  LeftMenuViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/10/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import SDWebImage

let passListNotificationKey:String = "com.8pon.choseSavedPlaylistAndContinueToCurrentVideo"

class LeftMenuViewController: UITableViewController {
    
    var savedPlaylist = [String]()
    var savedPlaylistNames = [String: String]()
    var savedPlaylistProgressName = [String: String]()
    var savedPlaylistProgressImageUrl = [String: String]()
    var savedPlaylistProgressId = [String: String]()
    let rowHeight:CGFloat = UIScreen.mainScreen().bounds.size.height/6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any addtional setup after loading the view
        tableView.backgroundColor = themeColor
        tableView.separatorStyle = .None
        tableView.allowsSelection = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateList()
    }
    
    func updateList() {
        // Retrieve saved lists from NSUserDefault
        if let tempList = NSUserDefaults.standardUserDefaults().arrayForKey("savedPlaylist") as? [String] {
            self.savedPlaylist = tempList
        }
        if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistName") as? [String: String] {
            self.savedPlaylistNames = tempDict
        }
        if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressName") as? [String: String] {
            self.savedPlaylistProgressName = tempDict
        }
        if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressImageUrl") as? [String: String] {
            self.savedPlaylistProgressImageUrl = tempDict
        }
        if let tempDict = NSUserDefaults.standardUserDefaults().dictionaryForKey("playlistProgressId") as? [String: String] {
            self.savedPlaylistProgressId = tempDict
        }
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.rowHeight
    }
  
    // MARK: Tableview data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedPlaylist.count
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "    收藏节目列表"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! LeftMenuTableViewCell
        if self.savedPlaylist.count > 0 {
            if let listId:String = self.savedPlaylist[indexPath.row] as String {
                if let listTitle:String = self.savedPlaylistNames[listId]! as String {
                    cell.playlistName.text = listTitle
                }
                if let currentVideoName:String = self.savedPlaylistProgressName[listId]! as String {
                    cell.progressInfo.text = "播放进度： \(currentVideoName)"
                }
                if let currentVideoImage:String = self.savedPlaylistProgressImageUrl[listId]! as String {
                    cell.playlistImageView.sd_setImageWithURL(NSURL(string: currentVideoImage))
                }
            }
        }
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var dataDict = Dictionary<String, String>()
        if let selectedListId:String = self.savedPlaylist[indexPath.row] as String {
            dataDict["listId"] = selectedListId
            if let selectedListName:String = self.savedPlaylistNames[selectedListId]! as String {
                dataDict["listName"] = selectedListName
            }
            if let selectedVideoId:String = self.savedPlaylistProgressId[selectedListId]! as String {
                dataDict["videoId"] = selectedVideoId
            }
            if let selectedVideoName:String = self.savedPlaylistProgressName[selectedListId]! as String {
                dataDict["videoName"] = selectedVideoName
            }
        }
        // TODO: use notification to handle jumping through controllers
        NSNotificationCenter.defaultCenter().postNotificationName(passListNotificationKey, object: nil, userInfo: dataDict)
        self.sideMenuViewController.hideMenuViewController()
    }
    
}