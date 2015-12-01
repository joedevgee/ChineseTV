//
//  SearchBarViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/29/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import FontAwesomeKit
import SDWebImage
import Alamofire
import Async
import NVActivityIndicatorView
import Parse

let searchViewSize:CGSize = CGSize(width: UIScreen.mainScreen().bounds.width * 0.8, height: UIScreen.mainScreen().bounds.height * 0.8)
let searchNotificationKey:String = "com.8pon.foundSearchReulstAndContinuetoPlaylist"

class SearchBarViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var searchResults = [Playlist]()
    
    var mainContainer:UIView = UIView.newAutoLayoutView()
    var searchTextField:UITextField = UITextField.newAutoLayoutView()
    var searchButton:UIButton = UIButton.newAutoLayoutView()
    var closeButton:UIButton = UIButton.newAutoLayoutView()
    var resultTable:UITableView = UITableView.newAutoLayoutView()
    let pacMan = NVActivityIndicatorView(frame: CGRectZero, type: .Pacman, color: UIColor.whiteColor(), size: CGSize(width: 60, height: 60))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupViews()
        let exitTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("exitView"))
        self.view.addGestureRecognizer(exitTap)
        exitTap.delegate = self
    }
    
    // Check receiver of tap gesture
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view?.isDescendantOfView(self.resultTable) == true {
            return false
        }
        return true
    }
    
    func exitView() {
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.startSearch()
        return true
    }
    
    func startSearch() {
        if let searchText = self.searchTextField.text where searchText.characters.count > 0 {
            pacMan.hidden = false
            pacMan.startAnimation()
            self.view.endEditing(true)
            self.searchTextField.text = nil
            self.searchRequest(searchText)
        }
    }
    
    func searchRequest(searchTerm: String) {
        searchResults.removeAll(keepCapacity: true)
        // First do a search on the Parse database
        let query = PFQuery(className: "ChinesePlayList")
        query.whereKey("listName", containsString: searchTerm)
        query.findObjectsInBackgroundWithBlock {
            (objects, error) in
            if objects?.count > 0 && error == nil {
                // Successfully found items in parse database
                if let lists = objects {
                    for list in lists {
                        guard let listId = list["listID"] as? String else { print("getting list id failed"); break }
                        guard let listName = list["listName"] as? String else { print("getting list name failed"); break }
                        guard let listImage = list["thumbnailUrl"] as? String else { print("getting thumbnail failed"); break }
                        self.searchResults.append(Playlist(id: listId, name: listName, thumbnailUrl: listImage))
                    }
                    self.resultTable.hidden = false
                    self.closeButton.hidden = false
                    self.resultTable.reloadData()
                    self.pacMan.hidden = true
                }
            } else {
                // If not found anything
                // Continue the search on youtube
                Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/search?", parameters: ["part": "snippet", "q": searchTerm,"type": "playlist","key": googleApiKey], encoding: ParameterEncoding.URLEncodedInURL)
                    .responseJSON { response in
                        if let items:Array<Dictionary<NSObject, AnyObject>> = response.result.value?["items"] as? Array<Dictionary<NSObject, AnyObject>> {
                            self.processSearch(items)
                        }
                }
            }
        }
    }
    
    func processSearch(items: Array<Dictionary<NSObject, AnyObject>>) {
        
        for list in items {
            guard let listId = list["id"]!["playlistId"] as? String else { print("Getting list id failed");break }
            guard let listName = list["snippet"]!["title"] as? String else { print("Getting list name failed");break }
            guard let thumbnailUrl = list ["snippet"]!["thumbnails"]!!["default"]!!["url"] as? String else { print("Getting thumbnail failed");break }
            self.searchResults.append(Playlist(id: listId, name: listName, thumbnailUrl: thumbnailUrl))
        }
        resultTable.hidden = false
        resultTable.reloadData()
        pacMan.hidden = true
        closeButton.hidden = false
    }
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.clearColor()
        mainContainer.backgroundColor = UIColor.clearColor()
        
        searchTextField.placeholder = " 搜您想看的节目"
        searchTextField.backgroundColor = UIColor.whiteColor()
        searchTextField.textColor = UIColor.blackColor()
        searchTextField.textAlignment = .Left
        searchTextField.layer.cornerRadius = 5
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
        
        searchButton.setTitle("搜索", forState: .Normal)
        searchButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        searchButton.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        searchButton.addTarget(self, action: Selector("startSearch"), forControlEvents: .TouchUpInside)
        
        closeButton.setTitle("退出", forState: .Normal)
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFontOfSize(30)
        closeButton.backgroundColor = UIColor.clearColor()
        closeButton.hidden = true
        closeButton.addTarget(self, action: "exitView", forControlEvents: .TouchUpInside)
        
        resultTable.delegate = self
        resultTable.dataSource = self
        resultTable.registerClass(VideoListTableViewCell.self, forCellReuseIdentifier: "Cell")
        resultTable.separatorStyle = .None
        resultTable.backgroundColor = UIColor.clearColor()
        resultTable.hidden = true
        
        pacMan.hidden = true
        
        self.view.addSubview(mainContainer)
        mainContainer.addSubview(searchTextField)
        mainContainer.addSubview(searchButton)
        mainContainer.addSubview(resultTable)
        mainContainer.addSubview(pacMan)
        mainContainer.addSubview(closeButton)
        
        mainContainer.autoPinEdgeToSuperviewEdge(.Top)
        mainContainer.autoPinEdgeToSuperviewEdge(.Left)
        mainContainer.autoSetDimensionsToSize(searchViewSize)
        
        searchButton.autoPinEdgeToSuperviewEdge(.Right)
        searchButton.autoAlignAxis(.Horizontal, toSameAxisOfView: searchTextField)
        
        searchTextField.autoPinEdgeToSuperviewEdge(.Top)
        searchTextField.autoPinEdgeToSuperviewEdge(.Leading)
        searchTextField.autoPinEdge(.Right, toEdge: .Left, ofView: searchButton, withOffset: -10)
        searchTextField.autoSetDimension(.Height, toSize: 30)
        
        resultTable.autoPinEdge(.Top, toEdge: .Bottom, ofView: searchTextField, withOffset: 10)
        resultTable.autoPinEdgeToSuperviewEdge(.Leading)
        resultTable.autoPinEdgeToSuperviewEdge(.Trailing)
        resultTable.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 50, relation: .GreaterThanOrEqual)
        
        closeButton.autoPinEdgeToSuperviewEdge(.Leading)
        closeButton.autoPinEdgeToSuperviewEdge(.Trailing)
        closeButton.autoPinEdgeToSuperviewEdge(.Bottom)
        closeButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: resultTable)
        
        pacMan.autoPinEdge(.Top, toEdge: .Bottom, ofView: searchTextField, withOffset: 80)
        pacMan.autoAlignAxisToSuperviewAxis(.Vertical)
        
    }
    
    //MARK: TableView datasource and delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (UIScreen.mainScreen().bounds.width / 3.5) * 0.7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! VideoListTableViewCell
        
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()
        
        if let imageUrl:String = self.searchResults[indexPath.row].thumbnailUrl as String {
            cell.thumbnailImageView.sd_setImageWithURL(NSURL(string: imageUrl))
        }
        if let listName:String = self.searchResults[indexPath.row].name as String {
            cell.videoTitle.textColor = UIColor.blackColor()
            cell.videoTitle.text = listName
        }
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var dataDict = Dictionary<String, String>()
        guard let selectedListId:String = self.searchResults[indexPath.row].id as String else { print("no id ") }
        guard let selectedListName:String = self.searchResults[indexPath.row].name as String else { print("no name") }
        dataDict["listId"] = selectedListId
        dataDict["listName"] = selectedListName
        NSNotificationCenter.defaultCenter().postNotificationName(searchNotificationKey, object: nil, userInfo: dataDict)
        exitView()
    }
    
}

class Playlist {
    var id: String
    var name: String
    var thumbnailUrl: String
    init(id: String, name: String, thumbnailUrl: String) {
        self.id = id
        self.name = name
        self.thumbnailUrl = thumbnailUrl
    }
}
