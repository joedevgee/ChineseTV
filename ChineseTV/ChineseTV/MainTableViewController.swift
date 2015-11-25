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
        tableView.backgroundColor = dividerColor
        tableView.separatorStyle = .None
        tableView.allowsSelection = true
        // Add observe listen to user choosing side menu saved list
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: passListNotificationKey, object: nil)
    }
    
    func receivedNotification(sender: NSNotification) {
        if let data:Dictionary<String, String> = sender.userInfo as? Dictionary<String, String> {
            self.performSegueWithIdentifier("showPlayList", sender: data)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tabBarController!.tabBar.hidden = false
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
            if let descName:String = object!["listDesc"] as? String {
                cell?.listTitle.text = "\(title): \(descName)"
            }
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
        self.performSegueWithIdentifier("showPlayList", sender: indexPath)
    }
    
    // To connect to the player view controller
    
    func setupNavBar() {
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
    
    // Prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.title = "主页"
        if segue.identifier == "addPlayList" {
            
        } else if segue.identifier == "showPlayList" {
            let destVC = segue.destinationViewController as! PlayListTableViewController
            if let indexPath:NSIndexPath = sender as? NSIndexPath {
                if let listId:String = objectAtIndexPath(indexPath)!["listID"] as? String {
                    destVC.requestPlayList(listId)
                    destVC.currentListId = listId
                    if let listName:String = objectAtIndexPath(sender as? NSIndexPath)!["listName"] as? String {
                        destVC.currentListName = listName
                    }
                    // hide tabbar
                    tabBarController?.tabBar.hidden = true
                }
            } else if let data:Dictionary<String, String> = sender as? Dictionary<String, String> {
                Async.main {
                        destVC.requestPlayList(data["listId"]!)
                        destVC.currentListId = data["listId"]!
                        destVC.currentListName = data["listName"]!
                    }.main {
                        destVC.performSegueWithIdentifier("showVideo", sender: data)
                }
                
            }
        }
    }
    
}
