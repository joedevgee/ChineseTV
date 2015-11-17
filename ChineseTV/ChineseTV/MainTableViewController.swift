//
//  MainTableViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/9/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import SDWebImage
import Alamofire
import Async

class MainTableViewController: PFQueryTableViewController {
    
    var toggleButton = MenuButton(frame: CGRectMake(100, 100, 30, 30))
    
    let rowHeight:CGFloat = UIScreen.mainScreen().bounds.size.height/3
    
    // Configure parse query settings
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        parseClassName = "ChinesePlayList"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 35
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "ChinesePlayList"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 35
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        return query
    }
    // End of configuring parse

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavBar()
        self.view.backgroundColor = dividerColor
        tableView.backgroundColor = dividerColor
        tableView.separatorStyle = .None
        tableView.separatorColor = dividerColor
        tableView.allowsSelection = true
    }
    
    // Tableviewcontroller delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? MainTableViewCell
        if cell == nil {
            cell = MainTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        if let title:String = object!["listName"] as? String {
            cell?.listTitle.text = title
        }
        if let subtitle:String = object!["listSubtitle"] as? String {
            cell?.listSubtitle.text = subtitle
        }
        if let url:String = object!["thumbnailUrl"] as? String {
            cell?.thumbnailImage.sd_setImageWithURL(NSURL(string: url))
        }
        
        cell?.setNeedsUpdateConstraints()
        cell?.updateConstraintsIfNeeded()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("playVideo", sender: indexPath)
    }
    
    // To connect to the player view controller
    

    // MARK: - ENSideMenu Delegate
    
    func setupNavBar() {
        self.shyNavBarManager.scrollView = self.tableView
        let menuImage = UIImage(named: "ic_menu")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let menuButton = UIBarButtonItem(image: menuImage, style: .Plain, target: self, action: "toggle")
        navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addPlayList:"))
    }
    
    func toggle() {
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    func addPlayList(sender: UIBarButtonItem) {
        performSegueWithIdentifier("addPlayList", sender: sender)
    }
    
    func sideMenuWillOpen() {
    }
    
    func sideMenuWillClose() {
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        return true
    }
    
    func sideMenuDidClose() {
    }
    
    func sideMenuDidOpen() {
    }
    
    // Prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addPlayList" {
            
        } else if segue.identifier == "playVideo" {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            let destVC = segue.destinationViewController as! PlayListDetailViewController
            if let listId:String = objectAtIndexPath(sender as? NSIndexPath)!["listID"] as? String {
                destVC.currentListId = listId
                Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(1)&playlistId=\(listId)&key=\(googleApiKey)")
                    .responseJSON { response in
                        if let videoId:String = response.result.value!["items"]!![0]["snippet"]!!["resourceId"]!!["videoId"] as? String {
                                destVC.youtubePlayer.videoIdentifier = videoId
                        }
                }
            }
        }
    }
    
}
