//
//  SingleCategoryCollectionViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/11/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Async

class SingleCategoryCollectionViewController: PFQueryCollectionViewController {
    
    let screenWidth:CGFloat = UIScreen.mainScreen().bounds.width
    let screenHeight:CGFloat = UIScreen.mainScreen().bounds.height
    var navigationTitle:String = ""
    var segueName:String = ""
    
    // MARK:Configure parse query settings
    override init(collectionViewLayout layout: UICollectionViewLayout, className: String?) {
        super.init(collectionViewLayout: layout, className: className)
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
    override func queryForCollection() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        return query
    }
    // End of configuring parse
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "showSearchBar")
        
        self.view.backgroundColor = collectionBackColor
        collectionView?.backgroundColor = collectionBackColor
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
        navigationItem.title = nil
        // Add observe listen to user choosing side menu saved list
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNotification:", name: passListNotificationKey, object: nil)
        self.showLeftNavButton()
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
    
    func showSearchBar() {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchBar") as! SearchBarViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = true
        formSheetController.allowDismissByPanningPresentedView = true
        formSheetController.presentationController?.contentViewSize = searchViewSize
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func receivedNotification(sender: NSNotification) {
        if let data:Dictionary<String, String> = sender.userInfo as? Dictionary<String, String> {
            self.performSegueWithIdentifier(self.segueName, sender: data)
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
            self.performSegueWithIdentifier(self.segueName, sender: segueInfo)
        }
    }
    
    func toggle() {
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SingleCategoryCollectionCell
        
        guard let listTitle = object!["listName"] as? String else { return nil }
        guard let listDesc = object!["listDesc"] as? String else { return nil }
        guard let thumbnailUrl = object!["thumbnailUrl"] as? String else { return nil }
        
        cell.videoTitle.text = "\(listTitle): \(listDesc)"
        cell.videoThumbnailView.sd_setImageWithURL(NSURL(string: thumbnailUrl))
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        if let parseId:String = object!.objectId, nudSavedList = NSUserDefaults.standardUserDefaults().arrayForKey(savedListArray) as? [String] {
            if nudSavedList.contains(parseId) { cell.saveList.tintColor = themeColor } else { cell.saveList.tintColor = collectionBackColor }
        }
        
        return cell
    }
    
    // MARK: collection view delegate
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: screenWidth/2, height: screenHeight/3.9)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(self.segueName, sender: indexPath)
    }
    
    // MARK: prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationItem.title = self.navigationTitle
        if segue.identifier == self.segueName {
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
