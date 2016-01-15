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
import PureLayout

class MainTableViewController: PFQueryTableViewController {
    
    var toggleButton = MenuButton(frame: CGRectMake(100, 100, 30, 30))
    
    var scrollView = UIScrollView()
    var viewOneLabel = UILabel.newAutoLayoutView()
    var viewOneImageView = PFImageView.newAutoLayoutView()
    var viewTwoLabel = UILabel.newAutoLayoutView()
    var viewTwoImageView = PFImageView.newAutoLayoutView()
    var viewThreeLabel = UILabel.newAutoLayoutView()
    var viewThreeImageView = PFImageView.newAutoLayoutView()
    
    var splashed:Bool = false
    
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
        
        let animateDuration:Double = 1.7
        
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
        self.configureScrollView()
        self.getFeaturedList()
        NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "moveToNextPage", userInfo: nil, repeats: true)
        tableView.tableHeaderView = scrollView
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
        self.scrollView.backgroundColor = themeColor
        self.scrollView.frame = CGRectMake(0, 0, view.frame.width, view.frame.width*0.4)
        let scrollViewWidth:CGFloat = self.scrollView.frame.width
        let scrollViewHeight:CGFloat = self.scrollView.frame.height
        let viewOne = UIView(frame: CGRectMake(0,0,scrollViewWidth,scrollViewHeight))
        let viewTwo = UIView(frame: CGRectMake(scrollViewWidth,0,scrollViewWidth,scrollViewHeight))
        let viewThree = UIView(frame: CGRectMake(scrollViewWidth*2,0,scrollViewWidth,scrollViewHeight))
        view.addSubview(scrollView)
        self.scrollView.addSubview(viewOne)
        viewOne.addSubview(viewOneLabel)
        viewOneLabel.autoCenterInSuperview()
        viewOne.addSubview(viewOneImageView)
        viewOneImageView.autoPinEdgesToSuperviewEdges()
        self.scrollView.addSubview(viewTwo)
        viewTwo.addSubview(viewTwoLabel)
        viewTwoLabel.autoCenterInSuperview()
        viewTwo.addSubview(viewTwoImageView)
        viewTwoImageView.autoPinEdgesToSuperviewEdges()
        self.scrollView.addSubview(viewThree)
        viewThree.addSubview(viewThreeLabel)
        viewThreeLabel.autoCenterInSuperview()
        viewThree.addSubview(viewThreeImageView)
        viewThreeImageView.autoPinEdgesToSuperviewEdges()
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width*3, self.scrollView.frame.height)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.delegate = self
    }
    func moveToNextPage (){
        let pageWidth:CGFloat = CGRectGetWidth(self.scrollView.frame)
        let maxWidth:CGFloat = pageWidth * 3
        let contentOffset:CGFloat = self.scrollView.contentOffset.x
        var slideToX = contentOffset + pageWidth
        if  contentOffset + pageWidth == maxWidth{
            slideToX = 0
        }
        self.scrollView.scrollRectToVisible(CGRectMake(slideToX, 0, pageWidth, CGRectGetHeight(self.scrollView.frame)), animated: true)
    }
    
    // Get featured list from Parse
    // Show them on the header scroll banner view
    private func getFeaturedList() {
        let query = PFQuery(className: "FeaturedList")
        query.limit = 3
        query.findObjectsInBackgroundWithBlock {
            (objects, error) in
            if objects?.count > 0 && error == nil {
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
                            self.showFeaturedList(newList, nameLabel: self.viewOneLabel, listImage: self.viewOneImageView, rank: 0)
                        case 1:
                            self.showFeaturedList(newList, nameLabel: self.viewTwoLabel, listImage: self.viewTwoImageView, rank: 1)
                        case 2:
                            self.showFeaturedList(newList, nameLabel: self.viewThreeLabel, listImage: self.viewThreeImageView, rank: 2)
                        default:
                            print("No matching list")
                        }
                        self.featuredList.append(newList)
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
