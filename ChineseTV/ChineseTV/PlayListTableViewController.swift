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
import NVActivityIndicatorView
import FontAwesomeKit
import GoogleMobileAds
import PureLayout

class PlayListTableViewController: UITableViewController {
    
    var currentListId:String?
    var currentListName:String?
    var parseObjectId:String?
    var nextPageToken:String?
    var tokenCheck = [String: Bool]()
    var videoList: [Video] = []
    var savedPlaylist: [String] = []
    var listProgressName = [String: String]()
    var listProgressImageUrl = [String: String]()
    var listProgressId = [String: String]()
    var listName = [String: String]()
    let indicatorView:UIView = UIView.newAutoLayoutView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        tableView.separatorStyle = .None
        self.addIndicator()
        guard let viewShowed:Bool = NSUserDefaults.standardUserDefaults().boolForKey("listViewShowed") else { return }
        if !viewShowed {
            let tutorialBar = TTGSnackbar.init(message: "点击右上角加号可以收藏当前节目", duration: TTGSnackbarDuration.Long)
            tutorialBar.show()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "listViewShowed")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard let savedList:[String] = NSUserDefaults.standardUserDefaults().arrayForKey(savedListArray) as? [String] else { navAddButton();return }
        if self.parseObjectId != nil {
            switch savedList.contains(self.parseObjectId!) {
            case true:
                navCancelButton()
            case false:
                navAddButton()
            }
        }
    }
    
    func addIndicator() {
        
        self.view.addSubview(indicatorView)
        
        indicatorView.autoSetDimensionsToSize(CGSize(width: 120, height: 120))
        
        let pacMan = NVActivityIndicatorView(frame: CGRectZero, type: .Pacman, color: themeColor, size: CGSize(width: 50, height: 50))
        pacMan.startAnimation()
        self.view.addSubview(pacMan)
        pacMan.autoCenterInSuperview()
        
        let loadingLabel = UILabel()
        loadingLabel.text = "抓取数据中"
        loadingLabel.textColor = themeColor
        loadingLabel.font = UIFont.systemFontOfSize(15)
        loadingLabel.textAlignment = .Center
        
        indicatorView.hidden = false
        
        indicatorView.addSubview(pacMan)
        indicatorView.addSubview(loadingLabel)
        
        indicatorView.autoCenterInSuperview()
        
        pacMan.autoCenterInSuperview()
        loadingLabel.autoAlignAxis(.Vertical, toSameAxisOfView: indicatorView)
        loadingLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: pacMan, withOffset: 25)
        
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
        guard let nudSavedList:[String] = NSUserDefaults.standardUserDefaults().arrayForKey(savedListArray) as? [String] else { self.firstSaving();return }
        if self.parseObjectId != nil && self.currentListName != nil {
            switch nudSavedList.contains(self.currentListId!) {
            case true:
                print("User has already saved this list")
                self.navCancelButton()
            case false:
                // Save the current list to user's saved list
                var savingNewListArray = nudSavedList
                savingNewListArray.append(self.parseObjectId!)
                NSUserDefaults.standardUserDefaults().setObject(savingNewListArray, forKey: savedListArray)
                // save video name
                guard let nudSavedListVideoName:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoNameDict) as? [String: String] else { break }
                var savingNewVideoNameDict = nudSavedListVideoName
                savingNewVideoNameDict[self.parseObjectId!] = self.videoList.first?.name
                NSUserDefaults.standardUserDefaults().setObject(savingNewVideoNameDict, forKey: savedVideoNameDict)
                // save video thumbnail url
                guard let nudSavedListVideoImage:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoImageDict) as? [String: String] else { break }
                var savingNewVideoImageDict = nudSavedListVideoImage
                savingNewVideoImageDict[self.parseObjectId!] = self.videoList.first?.thumbnailUrl
                NSUserDefaults.standardUserDefaults().setObject(savingNewVideoImageDict, forKey: savedVideoImageDict)
                // save video id
                guard let nudSavedVideoId:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoIdDict) as? [String: String] else { break }
                var savingNewVideoId = nudSavedVideoId
                savingNewVideoId[self.parseObjectId!] = self.videoList.first?.id
                NSUserDefaults.standardUserDefaults().setObject(savingNewVideoId, forKey: savedVideoIdDict)
                // save list name
                guard let nudSavedListName:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedListNameDict) as? [String: String] else { break }
                var savingNewListName = nudSavedListName
                savingNewListName[self.parseObjectId!] = self.currentListName!
                NSUserDefaults.standardUserDefaults().setObject(savingNewListName, forKey: savedListNameDict)
                // change nav bar
                self.navCancelButton()
                let successBar = TTGSnackbar.init(message: "您已成功收藏该节目", duration: TTGSnackbarDuration.Middle)
                successBar.show()
            }
        } else {
            print("current list id or current list name is empty")
        }
    }
    // User has never saved any list before
    // Firsttime saving activity occur
    private func firstSaving() {
        guard let listID:String = self.parseObjectId else { return }
        guard let listName:String = self.currentListName else { return }
        guard let videoName:String = self.videoList.first?.name else { return }
        guard let videoImage:String = self.videoList.first?.thumbnailUrl else { return }
        guard let videoId:String = self.videoList.first?.id else { return }
        // Save list id to saved list array
        var savingNewListArray = [String]()
        savingNewListArray.append(listID)
        NSUserDefaults.standardUserDefaults().setObject(savingNewListArray, forKey: savedListArray)
        // use dictionary to save list name matching list id
        var savingListNameDict = [String: String]()
        savingListNameDict[listID] = listName
        NSUserDefaults.standardUserDefaults().setObject(savingListNameDict, forKey: savedListNameDict)
        // save the video name
        var savingVideoNameDict = [String: String]()
        savingVideoNameDict[listID] = videoName
        NSUserDefaults.standardUserDefaults().setObject(savingVideoNameDict, forKey: savedVideoNameDict)
        // save the video thumbnail url
        var savingVideoImageDict = [String: String]()
        savingVideoImageDict[listID] = videoImage
        NSUserDefaults.standardUserDefaults().setObject(savingVideoImageDict, forKey: savedVideoImageDict)
        // save the video id
        var savingVideoIdDict = [String: String]()
        savingVideoIdDict[listID] = videoId
        NSUserDefaults.standardUserDefaults().setObject(savingVideoIdDict, forKey: savedVideoIdDict)
        // change nav bar
        self.navCancelButton()
        let successBar = TTGSnackbar.init(message: "您已成功收藏该节目", duration: TTGSnackbarDuration.Middle)
        successBar.show()
    }
    
    // let user delete current list
    func deleteList() {
        guard let nudSavedList:[String] = NSUserDefaults.standardUserDefaults().arrayForKey(savedListArray) as? [String] else { return }
        var savingNewList = nudSavedList
        if self.parseObjectId != nil {
            switch nudSavedList.contains(self.parseObjectId!) {
            case true:
                guard let deletingIndex = savingNewList.indexOf(self.parseObjectId!) else { break }
                guard let nudSavedListName:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedListNameDict) as? [String: String] else { break }
                var savingNewListNameDict = nudSavedListName
                guard let nudSavedVideoName:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoNameDict) as? [String: String] else { break }
                var savingNewVideoNameDict = nudSavedVideoName
                guard let nudSavedVideoImage:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoImageDict) as? [String: String] else { break }
                var savingNewVideoImageDict = nudSavedVideoImage
                guard let nudSavedVideoId:[String: String] = NSUserDefaults.standardUserDefaults().dictionaryForKey(savedVideoIdDict) as? [String: String] else { break }
                var savingNewVideoIdDict = nudSavedVideoId
                let snackBar = TTGSnackbar.init(message: "从收藏列表删除该节目？", duration: TTGSnackbarDuration.Middle, actionText: "确定")
                    { (snackBar) -> Void in
                        savingNewList.removeAtIndex(deletingIndex)
                        NSUserDefaults.standardUserDefaults().setObject(savingNewList, forKey: savedListArray)
                        savingNewListNameDict.removeValueForKey(self.parseObjectId!)
                        NSUserDefaults.standardUserDefaults().setObject(savingNewListNameDict, forKey: savedListNameDict)
                        savingNewVideoNameDict.removeValueForKey(self.parseObjectId!)
                        NSUserDefaults.standardUserDefaults().setObject(savingNewVideoNameDict, forKey: savedVideoNameDict)
                        savingNewVideoImageDict.removeValueForKey(self.parseObjectId!)
                        NSUserDefaults.standardUserDefaults().setObject(savingNewVideoImageDict, forKey: savedVideoImageDict)
                        savingNewVideoIdDict.removeValueForKey(self.parseObjectId!)
                        NSUserDefaults.standardUserDefaults().setObject(savingNewVideoIdDict, forKey: savedVideoIdDict)
                        self.navAddButton()
                }
                snackBar.show()
            case false:
                print("No need to do anything")
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowNumber = indexPath.row
        if rowNumber > 1 && rowNumber % 8 == 0 {
            return (UIScreen.mainScreen().bounds.width / 3.5) * 0.7 + 65
        } else {
            return (UIScreen.mainScreen().bounds.width / 3.5) * 0.7
        }
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
        let rowNumber = indexPath.row
        if rowNumber > 1 && rowNumber % 8 == 0 {
            // display cell with advertise
            let cell = tableView.dequeueReusableCellWithIdentifier("AdCell") as! VideoAdListTableViewCell
            cell.contentView.backgroundColor = UIColor.whiteColor()
            if let imageUrl:String = self.videoList[indexPath.row].shareImageUrl as String {
                let placeholderImage = UIImage(named: "Icon-Small")
                cell.thumbnailImageView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: placeholderImage)
            }
            if let videoTitle:String = self.videoList[indexPath.row].name as String {
                cell.videoTitle.text = videoTitle
                cell.videoTitle.textColor = UIColor.blackColor()
            }
            
            cell.bannerView.adUnitID = googleAdUnitId
            cell.bannerView.rootViewController = self
            let request = GADRequest()
            request.testDevices = ["91b007bf71861f769b8e96af7b5922c3", kGADSimulatorID]
            request.gender = .Female
            cell.bannerView.loadRequest(request)
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else {
            // display cell without ads
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! VideoListTableViewCell
            cell.contentView.backgroundColor = UIColor.whiteColor()
            if let imageUrl:String = self.videoList[indexPath.row].shareImageUrl as String {
            let placeholderImage = UIImage(named: "Icon-Small")
            cell.thumbnailImageView.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: placeholderImage)
            }
            if let videoTitle:String = self.videoList[indexPath.row].name as String {
                cell.videoTitle.text = videoTitle
                cell.videoTitle.textColor = UIColor.blackColor()
            }
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }
        
    }

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.nextPageToken != nil && indexPath.row == self.videoList.count - 10 && self.tokenCheck[self.nextPageToken!] != true {
            self.requestPlayList(self.currentListId!, pageToken: self.nextPageToken)
            self.tokenCheck[self.nextPageToken!] = true
        }
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
                if let tempString = response.result.value?["nextPageToken"] as? String where tempString != self.nextPageToken { self.nextPageToken = tempString; self.tokenCheck[tempString] = false }
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
        tableView.reloadData()
        self.indicatorView.hidden = true
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
            if self.parseObjectId != nil {
                destVC.parseListId = self.parseObjectId!
            }
            if self.videoList.count > 0 {
                destVC.videoList = self.videoList
                if self.nextPageToken != nil { destVC.nextVideoPageToken = self.nextPageToken }
            } else {
                destVC.requestPlayList(self.currentListId!, pageToken: nil)
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
