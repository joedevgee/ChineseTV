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
import FontAwesomeKit
import CBZSplashView

class MainTableViewController: PFQueryTableViewController {
    
    var toggleButton = MenuButton(frame: CGRectMake(100, 100, 30, 30))
    
    var splashed:Bool = false
    
    let rowHeight:CGFloat = UIScreen.mainScreen().bounds.size.height/3
    
    // Configure parse query settings
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        parseClassName = "ChinesePlayList"
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 60
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "ChinesePlayList"
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 60
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        return query
    }
    // End of configuring parse
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let animateDuration:Double = 2.0
        
        // logo splash
        tabBarController!.tabBar.hidden = true
        let playIcon:FAKFontAwesome = FAKFontAwesome.playIconWithSize(50)
        playIcon.addAttribute(NSForegroundColorAttributeName, value: themeColor)
        playIcon.drawingBackgroundColor = UIColor.clearColor()
        let placeholderImage:UIImage = playIcon.imageWithSize(CGSize(width: 50, height: 50))
        let splashView = CBZSplashView(icon: placeholderImage, backgroundColor: themeColor)
        self.view.addSubview(splashView)
        splashView.animationDuration = CGFloat(animateDuration)
        splashView.startAnimation()
        
        Async.main(after: animateDuration/2) {
            self.setupNavBar()
            self.splashed = true
        }
        
        tableView.backgroundColor = dividerColor
        tableView.separatorStyle = .None
        tableView.allowsSelection = true
    
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = nil
        super.viewWillAppear(true)
        if self.splashed {
            tabBarController!.tabBar.hidden = false
        }
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

        let placeholderImage = UIImage(named: "Icon-Small")
        cell?.thumbnailImage.sd_setImageWithURL(NSURL(string: thumbnailUrl), placeholderImage: placeholderImage)
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
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addPlayList:"))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "showSearchBar")
        tabBarController?.tabBar.hidden = false
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
                    destVC.requestPlayList(listId, pageToken: nil)
                    destVC.currentListId = listId
                    if let listName:String = objectAtIndexPath(sender as? NSIndexPath)!["listName"] as? String {
                        destVC.currentListName = listName
                    }
                }
            } else if let data:Dictionary<String, String> = sender as? Dictionary<String, String> {
                Async.main {
                    destVC.requestPlayList(data["listId"]!, pageToken: nil)
                    destVC.currentListId = data["listId"]!
                    destVC.currentListName = data["listName"]!
                    }.main {
                        destVC.performSegueWithIdentifier("showVideo", sender: data)
                }
                
            } else if let segueInfo:Array<String> = sender as? Array<String> {
                destVC.requestPlayList(segueInfo[0], pageToken: nil)
                destVC.currentListId = segueInfo[0]
                destVC.currentListName = segueInfo[1]
            }
        }
    }
    
}
