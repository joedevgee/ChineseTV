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
    
    // Configure parse query settings
    override init(collectionViewLayout layout: UICollectionViewLayout, className: String?) {
        super.init(collectionViewLayout: layout, className: className)
        parseClassName = "ChinesePlayList"
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 20
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "ChinesePlayList"
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 20
    }
    override func queryForCollection() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        return query
    }
    // End of configuring parse
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuImage = UIImage(named: "ic_menu")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let menuButton = UIBarButtonItem(image: menuImage, style: .Plain, target: self, action: "toggle")
        navigationItem.leftBarButtonItem = menuButton
        
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove observer that listens for side menu touch
        NSNotificationCenter.defaultCenter().removeObserver(self, name: passListNotificationKey, object: nil)
    }
    
    func receivedNotification(sender: NSNotification) {
        if let data:Dictionary<String, String> = sender.userInfo as? Dictionary<String, String> {
            self.performSegueWithIdentifier(self.segueName, sender: data)
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
        
        if let listId = object!["listID"] as? String, savedListArray = NSUserDefaults.standardUserDefaults().arrayForKey("savedPlaylist") as? [String] {
            if savedListArray.contains(listId) { cell.saveList.tintColor = themeColor } else { cell.saveList.tintColor = collectionBackColor }
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
        return CGSize(width: screenWidth/2, height: screenHeight/2.8)
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
                
            }
        }
    }
    
}
