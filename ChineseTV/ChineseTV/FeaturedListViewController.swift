//
//  FeaturedListViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 1/3/16.
//  Copyright © 2016 Qiaowei Liu. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import PureLayout

class FeaturedListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var featuredList = [FeaturedList]()
    
    var featuredTable = UITableView.newAutoLayoutView()
    var didSetupConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        featuredTable.delegate = self
        featuredTable.dataSource = self
        featuredTable.registerClass(EditFeaturedTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.requestData()
    }

    override func loadView() {
        view = UIView()
        featuredTable.backgroundColor = UIColor.clearColor()
        view.addSubview(featuredTable)
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            featuredTable.autoPinEdgesToSuperviewEdges()
            self.didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
    
    // MARK: Query parse for the featured lists data
    private func requestData() {
        let query = PFQuery(className: "FeaturedList")
        query.findObjectsInBackgroundWithBlock {
            (objects, error) in
            if objects?.count > 0 && error == nil {
                if let lists = objects {
                    for list in lists {
                        guard let listId = list["listId"] as? String else { print("Getting list id failed");continue }
                        guard let listName = list["listName"] as? String else { print("Getting list name failed");continue }
                        guard let image = list["Image"] as? PFFile else { print("Getting image failed");continue }
                        guard let objectId = list.objectId else { continue }
                        self.featuredList.append(FeaturedList(id: listId, name: listName, image: image, objectId: objectId))
                    }
                    self.featuredTable.reloadData()
                }
            }
        }
    }
    
    // MARK: tableview datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.featuredList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EditFeaturedTableViewCell
        if let image:PFFile = self.featuredList[indexPath.row].image as PFFile {
            cell.listImageView.file = image
            cell.listImageView.loadInBackground()
        }
        if let name:String = self.featuredList[indexPath.row].name as String {
            cell.listNameLabel.text = name
        }
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let list: FeaturedList = self.featuredList[indexPath.row] as FeaturedList {
            performSegueWithIdentifier("editFeatured", sender: list)
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.width * 0.6
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editFeatured" {
            guard let list:FeaturedList = sender as? FeaturedList else { print("Sending list failed");return }
            let destVC = segue.destinationViewController as! EditFeaturedViewController
            destVC.updateListInfo(list.name, image: list.image, parseId: list.objectId)
        }
    }
}


class FeaturedList {
    var id: String
    var name: String
    var image: PFFile
    var objectId: String
    init(id: String, name: String, image: PFFile, objectId: String) {
        self.id = id
        self.name = name
        self.image = image
        self.objectId = objectId
    }
}
