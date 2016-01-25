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
import PureLayout
import GoAutoSlideView

class MainTableViewController: PFQueryTableViewController, GoAutoSlideViewDataSource, GoAutoSlideViewDelegate {
    
    var toggleButton = MenuButton(frame: CGRectMake(100, 100, 30, 30))
    
    var scrollView = UIScrollView()
    var gotFeatured = false
    var headerScroll = GoAutoSlideView()
    var viewOneLabel = UILabel.newAutoLayoutView()
    var viewOneImageView = PFImageView.newAutoLayoutView()
    var viewTwoLabel = UILabel.newAutoLayoutView()
    var viewTwoImageView = PFImageView.newAutoLayoutView()
    var viewThreeLabel = UILabel.newAutoLayoutView()
    var viewThreeImageView = PFImageView.newAutoLayoutView()
    
    let rowHeight:CGFloat = UIScreen.mainScreen().bounds.size.height/3
    
    var featuredList = [FeaturedList]()
    
    // Configure parse query settings
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        parseClassName = "ChinesePlayList"
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 100
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "ChinesePlayList"
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 100
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        return query
    }
    // End of configuring parse
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController!.tabBar.hidden = true
        self.setupNavBar()
        tableView.backgroundColor = dividerColor
        tableView.separatorStyle = .None
        tableView.allowsSelection = true
        self.configureScrollView()
        self.getFeaturedList()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateHeader:"), name: "FinishedFeaturedList", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = nil
        super.viewWillAppear(true)
            tabBarController!.tabBar.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showLeftNavButton()
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
    
    private func showLeftNavButton() {
        if let tempList:[String] = NSUserDefaults.standardUserDefaults().arrayForKey(savedListArray) as? [String] {
            if tempList.isEmpty {
                navigationItem.leftBarButtonItem = nil
                self.sideMenuViewController.panGestureEnabled = false
            } else {
                let menuImage = UIImage(named: "ic_menu")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                let menuButton = UIBarButtonItem(image: menuImage, style: .Plain, target: self, action: "toggle")
                navigationItem.leftBarButtonItem = menuButton
                self.sideMenuViewController.panGestureEnabled = true
            }
        } else {
            self.sideMenuViewController.panGestureEnabled = false
            navigationItem.leftBarButtonItem = nil
        }
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
            guard let parseListId:String = data["parseId"]! as String else { print("no parse id") }
            segueInfo.append(listId)
            segueInfo.append(listName)
            segueInfo.append(parseListId)
            self.performSegueWithIdentifier("showPlayList", sender: segueInfo)
        }
    }
    
    // MARK: Add a scroll banner view on top of the tableview
    private func configureScrollView() {
        headerScroll = GoAutoSlideView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width * 0.4))
        headerScroll.slideDuration = 5
        headerScroll.slideDelegate = self
        headerScroll.slideDataSource = self
        headerScroll.currentPageIndicatorColor = themeColor
        tableView.tableHeaderView = headerScroll
    }
    func updateHeader(sender: NSNotification) {
        headerScroll.reloadData()
    }
    // MARK: goautoscroll view data source
    func numberOfPagesInGoAutoSlideView(goAutoSlideView: GoAutoSlideView) -> Int {
        return 3
    }
    func goAutoSlideView(goAutoSlideView: GoAutoSlideView, viewAtPage page: Int) -> UIView {
        let featuredView = PFImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width * 0.4))
        featuredView.contentMode = .ScaleAspectFill
        if gotFeatured {
            guard let featuredItem:FeaturedList = self.featuredList[page] else { print("Failed getting featured item") }
            featuredView.file = featuredItem.image
            featuredView.loadInBackground()
        } else {
            featuredView.backgroundColor = themeColor
        }
        return featuredView
    }
    func goAutoSlideView(goAutoSlideView: GoAutoSlideView, didTapViewPage page: Int) {
        if gotFeatured {
            
        }
    }
    
    // Get featured list from Parse
    // Show them on the header scroll banner view
    private func getFeaturedList() {
        Async.background {
            let query = PFQuery(className: "FeaturedList")
            query.limit = 3
            query.findObjectsInBackgroundWithBlock {
                (objects, error) in
                if objects?.count > 0 && error == nil {
                    let str = "hahah"
                    guard let emptyData = str.dataUsingEncoding(NSUTF8StringEncoding) else { return }
                    guard let emptyFile = PFFile(data: emptyData) else { return }
                    let emptyFeaturedItem = FeaturedList(id: "", name: "", image: emptyFile, objectId: "")
                    self.featuredList = [emptyFeaturedItem, emptyFeaturedItem, emptyFeaturedItem]
                    if let lists = objects {
                        for list in lists {
                            guard let listId = list["listId"] as? String else { print("Getting list id failed");continue }
                            guard let listName = list["listName"] as? String else { print("Getting list name failed");continue }
                            guard let image = list["Image"] as? PFFile else { print("Getting image failed");continue }
                            guard let rank = list["rank"] as? Int else { print("Getting list rank failed");continue }
                            guard let objectId = list.objectId else { continue }
                            let newList = FeaturedList(id: listId, name: listName, image: image, objectId: objectId)
                            switch rank {
                            case 0:
                                self.featuredList[0] = newList
                            case 1:
                                self.featuredList[1] = newList
                            case 2:
                                self.featuredList[2] = newList
                            default:
                                print("No matching list")
                            }
                        }
                        // Done with getting featured list from parse in the background
                        // Update the header scroll view
                        self.gotFeatured = true
                        NSNotificationCenter.defaultCenter().postNotificationName("FinishedFeaturedList", object: nil)
                    }
                }
            }
        }
    }
    private func showFeaturedList(list: FeaturedList, nameLabel: UILabel, listImage: PFImageView, rank: Int) {
        nameLabel.text = list.name
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.textAlignment = .Center
        nameLabel.font = UIFont.boldSystemFontOfSize(20)
        nameLabel.numberOfLines = 1
        
        listImage.contentMode = .ScaleAspectFill
        listImage.backgroundColor = UIColor.clearColor()
        listImage.clipsToBounds = true
        listImage.file = list.image
        listImage.loadInBackground()
        listImage.tag = rank
        let tap = UITapGestureRecognizer(target: self, action: "toFeaturedList:")
        listImage.userInteractionEnabled = true
        listImage.addGestureRecognizer(tap)
    }
    func toFeaturedList(sender: UITapGestureRecognizer) {
        if let viewTag = sender.view?.tag {
            guard let sendingList:FeaturedList = self.featuredList[viewTag] as FeaturedList else { return }
            var segueInfo = Array<String>()
            segueInfo.append(sendingList.id)
            segueInfo.append(sendingList.name)
            segueInfo.append(sendingList.objectId)
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
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addPlayList:"))
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: Selector("addFeatured:"))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "showSearchBar")
        tabBarController?.tabBar.hidden = false
    }
    
    func toggle() {
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    func addPlayList(sender: UIBarButtonItem) {
        performSegueWithIdentifier("addPlayList", sender: sender)
    }
    
    func addFeatured(sender: UIBarButtonItem) {
        performSegueWithIdentifier("featuredList", sender: sender)
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
                guard let listId:String = objectAtIndexPath(indexPath)!["listID"] as? String else { return }
                guard let listName:String = objectAtIndexPath(indexPath)!["listName"] as? String else { return }
                guard let parseId:String = objectAtIndexPath(indexPath)!.objectId else { return }
                destVC.requestPlayList(listId, pageToken: nil)
                destVC.currentListId = listId
                destVC.currentListName = listName
                destVC.parseObjectId = parseId
            } else if let data:Dictionary<String, String> = sender as? Dictionary<String, String> {
                Async.main {
                    destVC.requestPlayList(data["listId"]!, pageToken: nil)
                    destVC.currentListId = data["listId"]!
                    destVC.currentListName = data["listName"]!
                    destVC.parseObjectId = data["parseId"]!
                    }.main {
                        destVC.performSegueWithIdentifier("showVideo", sender: data)
                }
                
            } else if let segueInfo:Array<String> = sender as? Array<String> {
                destVC.requestPlayList(segueInfo[0], pageToken: nil)
                destVC.currentListId = segueInfo[0]
                destVC.currentListName = segueInfo[1]
                destVC.parseObjectId = segueInfo[2]
            }
        }
    }
    
}
