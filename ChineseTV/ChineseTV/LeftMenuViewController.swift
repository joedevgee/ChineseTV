//
//  LeftMenuViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/10/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import Parse
import SDWebImage

let passListNotificationKey:String = "com.8pon.choseSavedPlaylistAndContinueToCurrentVideo"

class LeftMenuViewController: UITableViewController {
    
    var savedPlaylist = [String]()
    var savedPlaylistIds = [String: String]()
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
        guard let nudSavedList:[String] = NSUserDefaults.standardUserDefaults().arrayForKey(savedListArray) as? [String] else { print("no saved play list");return }
        guard let nudListNames:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedListNameDict) as? [String: String] else { print("failed getting list name");return }
        guard let nudListProgressName:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoNameDict) as? [String: String] else { print("failed getting video name");return }
        guard let nudImageUrl:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoImageDict) as? [String: String] else { print("failed getting image url");return }
        guard let nudVideoId:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoIdDict) as? [String: String] else { print("failed getting video id");return }
        savedPlaylist = nudSavedList
        savedPlaylistNames = nudListNames
        savedPlaylistProgressName = nudListProgressName
        savedPlaylistProgressImageUrl = nudImageUrl
        savedPlaylistProgressId = nudVideoId
        // Fetch list info (mainly youtube playlist id from parse)
        for list in nudSavedList {
            let query = PFQuery(className: "ChinesePlayList")
            query.getObjectInBackgroundWithId(list) {
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil && object != nil {
                    guard let playlistId = object!["listID"] as? String else { return }
                    self.savedPlaylistIds[list] = playlistId
                }
            }
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! LeftMenuTableViewCell
        switch self.savedPlaylist.isEmpty {
        case true:
            print("List is empty")
        case false:
            // Update the cell
            guard let listID:String = self.savedPlaylist[indexPath.row] as String else { break }
            guard let listTitle:String = self.savedPlaylistNames[listID]! as String else { break }
            guard let videoName:String = self.savedPlaylistProgressName[listID]! as String else { break }
            guard let videoImage:String = self.savedPlaylistProgressImageUrl[listID]! as String else { break }
            cell.playlistName.text = listTitle
            cell.progressInfo.text = "播放进度： \(videoName)"
            cell.playlistImageView.sd_setImageWithURL(NSURL(string: videoImage))
        }
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var dataDict = Dictionary<String, String>()
        switch self.savedPlaylist.isEmpty {
        case true:
            print("There is no list to direct to")
        case false:
            guard let parseId:String = self.savedPlaylist[indexPath.row] as String else { break }
            guard let listID:String = self.savedPlaylistIds[parseId]! as String else { break }
            guard let listTitle:String = self.savedPlaylistNames[parseId]! as String else { break }
            guard let videoID:String = self.savedPlaylistProgressId[parseId]! as String else { break }
            guard let videoName:String = self.savedPlaylistProgressName[parseId]! as String else { break }
            dataDict["parseId"] = parseId
            dataDict["listId"] = listID
            dataDict["listName"] = listTitle
            dataDict["videoId"] = videoID
            dataDict["videoName"] = videoName
//             TODO: use notification to handle jumping through controllers
            NSNotificationCenter.defaultCenter().postNotificationName(passListNotificationKey, object: nil, userInfo: dataDict)
        }
        self.sideMenuViewController.hideMenuViewController()
    }
    
}