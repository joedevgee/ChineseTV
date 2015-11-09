//
//  LeftMenuViewController.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/22/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import Parse
import ParseUI
import SDWebImage

class LeftMenuViewController: PFQueryTableViewController {
    
    let headerHeight:CGFloat = UIScreen.mainScreen().bounds.size.height*0.25
    let rowHeight:CGFloat = UIScreen.mainScreen().bounds.size.height/9
    
    // Configure parse query settings
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        parseClassName = "YoutubeChannel"
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "YoutubeChannel"
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 20
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        
        query.orderByDescending("subscriberCount")
        
        return query
    }
    // End of configuring parse
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any addtional setup after loading the view
        tableView.backgroundColor = sideMenuColor
        tableView.separatorStyle = .None
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = true
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("Header") as! LeftMenuHeaderCell
        let tapOnHeader:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("headerTapped"))
        headerCell.mainContainer.addGestureRecognizer(tapOnHeader)
        headerCell.setNeedsUpdateConstraints()
        headerCell.updateConstraintsIfNeeded()
        return headerCell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? LeftMenuTableViewCell
        if let channelName = object!["channelTitle"] as? String {
            cell?.categoryName.text = channelName
        }
        if let channelImage = object!["thumbnailUrl"] as? String {
            cell?.categoryImageView.sd_setImageWithURL(NSURL(string: channelImage))
        }
        cell?.setNeedsUpdateConstraints()
        cell?.updateConstraintsIfNeeded()
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedChannel = self.objectAtIndexPath(indexPath) {
            if let tempChannelId = selectedChannel["channelId"] as? String {
                passChannelId = tempChannelId
            }
            if let categoryName = selectedChannel["channelTitle"] as? String {
                passChannelTitle = categoryName
            }
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let categoryController: UIViewController = UINavigationController(rootViewController: storyBoard.instantiateViewControllerWithIdentifier("categoryController"))
        
        self.sideMenuViewController.setContentViewController(categoryController, animated: true)
        self.sideMenuViewController.hideMenuViewController()
    }
    
    func headerTapped() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainController:UIViewController = UINavigationController(rootViewController: storyBoard.instantiateViewControllerWithIdentifier("homeViewController"))
        self.sideMenuViewController.setContentViewController(mainController, animated: true)
        self.sideMenuViewController.hideMenuViewController()
    }
    
 
    
}