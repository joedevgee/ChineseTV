//
//  CategoryCollectionViewController.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/24/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import SDWebImage

class CategoryCollectionViewController: PFQueryCollectionViewController {
    
    private let reuseIdentifier = "Cell"
    
    // Configure parse query settings
    override init(collectionViewLayout layout: UICollectionViewLayout, className: String?) {
        super.init(collectionViewLayout: layout, className: className)
        parseClassName = "YoutubeVideo"
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 20
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "YoutubeVideo"
        pullToRefreshEnabled = false
        paginationEnabled = true
        objectsPerPage = 20
    }
    override func queryForCollection() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending("createdAt")
        if passChannelId != nil {
            query.whereKey("channelId", equalTo: passChannelId!)
            
        } else {
            print("There is no parent channel to look for")
        }
        
        return query
    }
    // End of configuring parse
    
    override func viewDidLoad() {
        
        let menuImage = UIImage(named: "ic_menu")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let menuButton = UIBarButtonItem(image: menuImage, style: .Plain, target: self, action: "menu:")
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addVideo:"))
        navigationItem.rightBarButtonItem?.enabled = false
        
        collectionView?.backgroundColor = themeBackgroundColor
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if passChannelId != nil {
            self.navigationItem.rightBarButtonItem?.enabled = true
            queryForCollection()
            loadObjects()
        }
        if passChannelTitle != nil {
            self.navigationItem.title = passChannelTitle
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    func addVideo(sender: UIBarButtonItem) {
        performSegueWithIdentifier("addVideo", sender: sender)
    }
    
    func menu(sender: UIBarButtonItem) {
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellHeight:CGFloat = UIScreen.mainScreen().bounds.size.height*0.35
        let cellWidth:CGFloat = UIScreen.mainScreen().bounds.size.width*0.45
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let screenWidth:CGFloat = UIScreen.mainScreen().bounds.size.width
        return UIEdgeInsets(top: 20, left: screenWidth*0.03, bottom: 0, right: screenWidth*0.03)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CategoryCollectionViewCell
        if let imageUrl = object!["standardImageUrl"] as? String {
            cell.videoThumbnailView.sd_setImageWithURL(NSURL(string: imageUrl))
        }
        if let videoTitle = object!["videoTitle"] as? String {
            cell.videoTitle.text = videoTitle
        }
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addVideo" {
            print("Adding video")
        } else if segue.identifier == "videoDetail" {
            navigationController?.setNavigationBarHidden(true, animated: false)
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
            let hitPoint = sender?.convertPoint(CGPointZero, toView: self.collectionView)
            let hitIndex = self.collectionView?.indexPathForItemAtPoint(hitPoint!)
            let video = objectAtIndexPath(hitIndex)
            let destVC = segue.destinationViewController as! VideoDetailTableViewController
            if let channelTitle = video!["channelTitle"] as? String {
                destVC.channelTitle = channelTitle
            }
            if let channelImageUrl = video!["channelImage"] as? String {
                destVC.channelImageUrl = channelImageUrl
            }
            if let youtubeID = video!["youtubeId"] as? String {
                destVC.youtubeID = youtubeID
            }
        }
    }

}

