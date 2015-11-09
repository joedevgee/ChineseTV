//
//  AddCategoryViewController.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/22/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import Parse
import SDWebImage
import Alamofire

class AddCategoryViewController: UIViewController, UITextFieldDelegate {
    
    var avatarImageView: UIImageView = UIImageView.newAutoLayoutView()
    var titleLabel: UILabel = UILabel.newAutoLayoutView()
    
    var viewCountParse: Int = 0
    var subscriberCountParse: Int = 0
    var channelBannerParse: String = " "
    var channelTitleParse: String = " "
    var channelIdParse: String = " "
    var channelDescParse: String = " "
    var channelImageDefaultParse: String = " "
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add function buttons to the navigation bar
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelAction:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "addChannel:")
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        // Check if youtube link existed in the paste board
        if let copyString = UIPasteboard.generalPasteboard().string {
            if copyString.rangeOfString("youtu.be/") != nil {
                // Retrieve the youtube link from pasteboard
                self.getYoutubeId(copyString)
            }
        }
    }
    
    func getYoutubeId(youtubeLink: String!) {
        if youtubeLink.characters.count >= 26 {
            let videoId = youtubeLink.substringFromIndex(youtubeLink.endIndex.advancedBy(-11))
            self.getVideoInfo(videoId)
        }
    }
    
    func getVideoInfo(videoId: String!) {
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/videos?key=\(googleApiKey)&part=snippet,statistics&id=\(videoId)")
            .responseJSON { response in
                if let JSON = response.result.value {
                    // Get the first video item
                    // Usually there is only one video item returned
                    if let items: AnyObject! = JSON["items"] as? Array<AnyObject>! {
                        if items.count > 0 {
                            self.processVideoInfo(items as! Array<AnyObject>)
                        } else {
                            print("No video fetched from youtube")
                        }
                    }
                    // End of getting the first video item
                }
        }
    }
    
    func getYoutubeChanelData(channelId: String!) {
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/channels?key=\(googleApiKey)&part=snippet,brandingSettings,statistics&id=\(channelId)")
            .responseJSON { response in
                if let JSON = response.result.value {
                    // Get the first channel item
                    // Usually there is only one channel item returned
                    if let items: AnyObject! = JSON["items"] as? Array<AnyObject>! {
                        if items.count > 0 {
                            self.processChannelInfo(items as! Array<AnyObject>)
                        } else {
                            print("No item returned from youtube")
                        }
                    }
                    // End of getting the first channel item
                }
        }
    }
    
    func processVideoInfo(items: Array<AnyObject>) {
        if let firstItemDict: Dictionary<NSObject, AnyObject> = items[0] as? Dictionary<NSObject, AnyObject> {
            if let snippetDict: Dictionary<NSObject, AnyObject> = firstItemDict["snippet"] as? Dictionary<NSObject, AnyObject> {
                if let channelId: String = snippetDict["channelId"] as? String {
                    self.getYoutubeChanelData(channelId)
                }
            } else {
                print("Getting snippet JSON failed")
            }
        } else {
            print("Failed getting first item")
        }
    }
    
    func processChannelInfo(items: Array<AnyObject>) {
        if let firstItemDict: Dictionary<NSObject, AnyObject> = items[0] as? Dictionary<NSObject, AnyObject> {
            // Getting statistics
            if let statDict: Dictionary<NSObject, AnyObject> = firstItemDict["statistics"] as? Dictionary<NSObject, AnyObject> {
                self.viewCountParse = Int(statDict["viewCount"] as! String)!
                self.subscriberCountParse = Int(statDict["subscriberCount"] as! String)!
            } else {
                print("Error: getting stat info")
            }
            // End of getting statistics
            
            // Getting branding settings
            if let brandingDict: Dictionary<NSObject, AnyObject> = firstItemDict["brandingSettings"] as? Dictionary<NSObject, AnyObject> {
                if let bannerDict: Dictionary<NSObject, AnyObject> = brandingDict["image"] as? Dictionary<NSObject, AnyObject> {
                    self.channelBannerParse = bannerDict["bannerMobileImageUrl"] as! String
                }
            } else {
                print("Error: getting branding settings")
            }
            // End of getting branding settings
            
            // Getting snippet
            if let snippetDict: Dictionary<NSObject, AnyObject> = firstItemDict["snippet"] as? Dictionary<NSObject, AnyObject> {
                self.channelTitleParse = snippetDict["title"] as! String
                self.titleLabel.text = self.channelTitleParse
                self.channelIdParse = firstItemDict["id"] as! String
                self.channelDescParse = snippetDict["description"] as! String
                if let thumbnailsDict: Dictionary<NSObject, AnyObject> = snippetDict["thumbnails"] as? Dictionary<NSObject, AnyObject> {
                    if let defaultUrl: String = thumbnailsDict["default"]?["url"] as? String {
                        self.channelImageDefaultParse = defaultUrl
                        self.avatarImageView.sd_setImageWithURL(NSURL(string: defaultUrl))
                    }
                }
            } else {
                print("Error: Getting snippet item")
            }
            // End of getting snippet
            self.showChannelInfo()
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            print("Error: getting first item")
        }

    }
    
    func addChannel(sender: UIBarButtonItem) {
        let savingChannel = PFObject(className: "YoutubeChannel")
        savingChannel["viewCount"] = self.viewCountParse
        savingChannel["subscriberCount"] = self.subscriberCountParse
        savingChannel["bannerUrl"] = self.channelBannerParse
        savingChannel["channelTitle"] = self.channelTitleParse
        savingChannel["channelId"] = self.channelIdParse
        savingChannel["channelDesc"] = self.channelDescParse
        savingChannel["thumbnailUrl"] = self.channelImageDefaultParse
        savingChannel.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                print("Channel saved successfully")
            } else {
                print("Channel save failed")
            }
        }
    }
    
    func showChannelInfo() {
        avatarImageView.autoSetDimensionsToSize(CGSize(width: 50, height: 50))
        avatarImageView.contentMode = .ScaleAspectFit
        titleLabel.font = UIFont.systemFontOfSize(18)
        titleLabel.textAlignment = .Center
        titleLabel.sizeToFit()
        self.view.addSubview(avatarImageView)
        self.view.addSubview(titleLabel)
        avatarImageView.autoCenterInSuperview()
        titleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 20)
        titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: avatarImageView, withOffset: 20)
    }
    
    func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
   
}
