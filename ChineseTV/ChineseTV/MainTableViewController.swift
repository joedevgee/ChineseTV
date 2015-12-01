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
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 35
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "ChinesePlayList"
        pullToRefreshEnabled = false
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
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Add observe listen to user choosing side menu saved list
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: passListNotificationKey, object: nil)
        // Add observer listen to user found search result
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "foundSearchResult:", name: searchNotificationKey, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove observer that listens for side menu touch
        NSNotificationCenter.defaultCenter().removeObserver(self, name: passListNotificationKey, object: nil)
        // Remove observer that listens to search bar view
        NSNotificationCenter.defaultCenter().removeObserver(self, name: searchNotificationKey, object: nil)
    }
    
    func receivedNotification(sender: NSNotification) {
        if let data:Dictionary<String, String> = sender.userInfo as? Dictionary<String, String> {
            self.performSegueWithIdentifier("showPlayList", sender: data)
        }
    }
    
    func foundSearchResult(sender: NSNotification) {
        if let data:Dictionary<String, String> = sender.userInfo as? Dictionary<String, String> {
            var segueInfo = Array<String>()
            guard let listId:String = data["listId"]! as String else { print("found no id") }
            guard let listName:String = data["listName"]! as String else { print("found no name") }
            segueInfo.append(listId)
            segueInfo.append(listName)
            self.performSegueWithIdentifier("showPlayList", sender: segueInfo)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tabBarController!.tabBar.hidden = false
    }
    
    // MARK:Tableviewcontroller delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? MainTableViewCell
        if cell == nil {
            cell = MainTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        guard let listTitle = object!["listName"] as? String else { return nil }
        guard let listDesc = object!["listDesc"] as? String else { return nil }
        guard let listSubtitle = object!["listSubtitle"] as? String else { return nil }
        guard let thumbnailUrl = object!["thumbnailUrl"] as? String else { return nil }
        cell?.listTitle.text = "\(listTitle): \(listDesc)"
        cell?.listSubtitle.text = "\(listSubtitle)"
        cell?.thumbnailImage.sd_setImageWithURL(NSURL(string: thumbnailUrl))
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
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "showSearchBar")
    }
    
    func toggle() {
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    func addPlayList(sender: UIBarButtonItem) {
        performSegueWithIdentifier("addPlayList", sender: sender)
    }
    
    func showSearchBar() {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchBar") as! SearchBarViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = true
        formSheetController.allowDismissByPanningPresentedView = true
        formSheetController.presentationController?.contentViewSize = searchViewSize
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    // Prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.title = "主页"
        if segue.identifier == "addPlayList" {
            
        } else if segue.identifier == "showPlayList" {
            tabBarController!.tabBar.hidden = true
            let destVC = segue.destinationViewController as! PlayListTableViewController
            if let indexPath:NSIndexPath = sender as? NSIndexPath {
                if let listId:String = objectAtIndexPath(indexPath)!["listID"] as? String {
                    destVC.requestPlayList(listId)
                    destVC.currentListId = listId
                    if let listName:String = objectAtIndexPath(sender as? NSIndexPath)!["listName"] as? String {
                        destVC.currentListName = listName
                    }
                }
            } else if let data:Dictionary<String, String> = sender as? Dictionary<String, String> {
                Async.main {
                        destVC.requestPlayList(data["listId"]!)
                        destVC.currentListId = data["listId"]!
                        destVC.currentListName = data["listName"]!
                    }.main {
                        destVC.performSegueWithIdentifier("showVideo", sender: data)
                }
                
            } else if let segueInfo:Array<String> = sender as? Array<String> {
                destVC.requestPlayList(segueInfo[0])
                destVC.currentListId = segueInfo[0]
                destVC.currentListName = segueInfo[1]
            }
        }
    }
    
}
