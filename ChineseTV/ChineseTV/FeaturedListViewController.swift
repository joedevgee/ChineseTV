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
        featuredTable.estimatedRowHeight = 80
        featuredTable.rowHeight = UITableViewAutomaticDimension
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
                        guard let listId = list["listId"] as? String else { break }
                        guard let listName = list["listName"] as? String else { break }
                        guard let image = list["Image"] as? PFFile else { break }
                        self.featuredList.append(FeaturedList(id: listId, name: listName, image: image))
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
        }
        if let name:String = self.featuredList[indexPath.row].name as String {
            cell.listNameLabel.text = name
        }
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    

}


class FeaturedList {
    var id: String
    var name: String
    var image: PFFile
    init(id: String, name: String, image: PFFile) {
        self.id = id
        self.name = name
        self.image = image
    }
}
