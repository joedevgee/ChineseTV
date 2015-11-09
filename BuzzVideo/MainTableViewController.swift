//
//  MainTableViewController.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/17/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import ParseFacebookUtilsV4
import SDWebImage
import Parse
import ParseUI
import TTGSnackbar

class MainTableViewController: PFQueryTableViewController {
    
    let rowHeight:CGFloat = UIScreen.mainScreen().bounds.size.height/3
    
    // Configure parse query settings
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        parseClassName = "YoutubeVideo"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 25
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "YoutubeVideo"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 25
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.whereKey("reviewPassed", equalTo: true)
        query.orderByDescending("updatedAt")
        return query
    }
    // End of configuring parse

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.shyNavBarManager.scrollView = self.tableView
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "toAddCategory:")
        let menuImage = UIImage(named: "ic_menu")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let menuButton = UIBarButtonItem(image: menuImage, style: .Plain, target: self, action: "menu:")
        navigationItem.leftBarButtonItem = menuButton
        
        tableView.backgroundColor = themeBackgroundColor
        tableView.separatorStyle = .None
        tableView.separatorColor = themeBackgroundColor
        tableView.allowsSelection = true

    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Check if the user has pasted a youtube link
        if let copyString = UIPasteboard.generalPasteboard().string {
            if copyString.rangeOfString("youtu.be/") != nil {
                let snackbar = TTGSnackbar.init(message: "Want to share a video?", duration: TTGSnackbarDuration.Long, actionText: "Yes")
                    { (snackbar) -> Void in
                        self.performSegueWithIdentifier("addVideo", sender: nil)
                        print("Let's add a video")
                }
                snackbar.show()
            }
        }
        // End of checking youtube link
        navigationItem.title = nil
        navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    func menu(sender: UIBarButtonItem) {
        self.sideMenuViewController.presentLeftMenuViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? MainTableViewCell
        if let imageUrl = object!["standardImageUrl"] as? String {
            cell?.thumbnailImage.sd_setImageWithURL(NSURL(string: imageUrl))
        }
        if let videoTitle = object!["videoTitle"] as? String {
            cell?.videoTitle.text = videoTitle
        }
        if let channelAvatar = object!["channelImage"] as? String {
            cell?.categoryImage.sd_setImageWithURL(NSURL(string: channelAvatar))
        }
        if let channelName = object!["channelTitle"] as? String {
            cell?.categoryName.text = channelName
        }
        if let viewCount = object!["viewCount"] as? Int {
            cell?.footerLabel.text = String(viewCount) + " views"
        }
        
        cell?.setNeedsUpdateConstraints()
        cell?.updateConstraintsIfNeeded()
        return cell
    }
    
    func toAddCategory(sender: UIBarButtonItem) {
        performSegueWithIdentifier("addCategory", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "videoDetail" {
            navigationController?.setNavigationBarHidden(true, animated: false)
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            self.navigationItem.title = "Home"
            let indexPath = self.tableView.indexPathForSelectedRow!
            let video = objectAtIndexPath(indexPath)
            let destVC = segue.destinationViewController as! VideoDetailTableViewController
            if let youtubeID = video!["youtubeId"] as? String {
                destVC.youtubeID = youtubeID
            }
            if let channelTitle = video!["channelTitle"] as? String {
                destVC.channelTitle = channelTitle
            }
            if let channelImageUrl = video!["channelImage"] as? String {
                destVC.channelImageUrl = channelImageUrl
            }
        } else if segue.identifier == "addCategory" {
            print("Add Category")
        }
    }
    
}
