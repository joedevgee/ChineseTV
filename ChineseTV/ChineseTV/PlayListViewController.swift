//
//  PlayListViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 12/9/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import SDWebImage
import TTGSnackbar
import NVActivityIndicatorView
import Alamofire

class PlayListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var videoList = Array<Video>()
    
    var currentListId:String?
    var currentListName:String?
    var nextPageToken:String?
    var tokenCheck = [String: Bool]()
    var savedPlaylist: [String] = []
    var listProgressName = [String: String]()
    var listProgressImageUrl = [String: String]()
    var listProgressId = [String: String]()
    var listName = [String: String]()
    let indicatorView:UIView = UIView.newAutoLayoutView()
    
    var videoListTableview:UITableView = UITableView.newAutoLayoutView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func setupNav() {
        if let viewShowed:Bool = NSUserDefaults.standardUserDefaults().boolForKey("listViewShowed") {
            if viewShowed == true {
                print("playlist view already showed before")
            } else {
                print("play list view is showing the first time")
                let tutorialBar = TTGSnackbar.init(message: "点击右上角加号可以收藏当前节目", duration: TTGSnackbarDuration.Long)
                tutorialBar.show()
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "listViewShowed")
            }
        }
    }
    
    private func setupUI() {
        videoListTableview.delegate = self
        videoListTableview.dataSource = self
        videoListTableview.registerClass(VideoListTableViewCell.self, forCellReuseIdentifier: "Cell")
        videoListTableview.separatorStyle = .None
        videoListTableview.backgroundColor = UIColor.clearColor()
        
        
        self.view.addSubview(videoListTableview)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videoList.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (UIScreen.mainScreen().bounds.width / 3.5) * 0.7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        return cell
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
        videoListTableview.reloadData()
//        self.indicatorView.hidden = true
    }
    
    
    //MARK: Prepare for segue
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showVideo" {
//            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
//            let destVC = segue.destinationViewController as! PlayListDetailViewController
//            if self.currentListId != nil {
//                destVC.currentListId = self.currentListId!
//            } else {
//                print("list id is nil")
//            }
//            if self.videoList.count > 0 {
//                destVC.videoList = self.videoList
//                if self.nextPageToken != nil { destVC.nextVideoPageToken = self.nextPageToken }
//            } else {
//                destVC.requestPlayList(self.currentListId!, pageToken: nil)
//            }
//            if let selectedVideo = sender as? Video {
//                destVC.youtubePlayer.videoIdentifier = selectedVideo.id
//                destVC.videoListHeaderTitle.text = "正在播放： " + selectedVideo.name
//            } else if let data:Dictionary<String, String> = sender as? Dictionary<String, String> {
//                destVC.youtubePlayer.videoIdentifier = data["videoId"]!
//                destVC.videoListHeaderTitle.text = "正在播放： " + data["videoName"]!
//            }
//        }
//    }

}
