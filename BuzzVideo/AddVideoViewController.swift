//
//  AddVideoViewController.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/24/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import Parse
import SDWebImage
import Alamofire
import LTMorphingLabel
import VBFPopFlatButton
import UIColor_Hex_Swift
import FlatUIKit
import TTGSnackbar

class AddVideoViewController: UIViewController, UITextFieldDelegate {
    
    var youtubeLinkField:UITextField = UITextField.newAutoLayoutView()
    var checkLinkButton:UIButton = UIButton.newAutoLayoutView()
    
    var videoContainer:UIView = UIView.newAutoLayoutView()
    
    let uploadButton = VBFPopFlatButton(frame: CGRectMake(200, 150, 30, 30), buttonType: FlatButtonType.buttonOkType, buttonStyle: FlatButtonStyle.buttonRoundedStyle, animateToInitialState: true)
    
    var topView:UIView = UIView.newAutoLayoutView()
    var bottomView:UIView = UIView.newAutoLayoutView()
    var categoryImage:UIImageView = UIImageView.newAutoLayoutView()
    var categoryName:LTMorphingLabel = LTMorphingLabel.newAutoLayoutView()
    var thumbnailImage:UIImageView = UIImageView.newAutoLayoutView()
    var videoTitle:LTMorphingLabel = LTMorphingLabel.newAutoLayoutView()
    
    var channelIdParse:String = " "
    var channelTitleParse:String = " "
    var channelImageParse:String = " "
    var defaultImageParse:String = " "
    var standardImageParse:String = " "
    var videoDescParse:String = " "
    var videoTitleParse:String = " "
    var viewCountParse:Int = 0
    var youtubeIDParse:String = " "
    var reviewPassedParse:Bool = false
    var savedObjectId:String = " "
    
    var videoSaved:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Configure the nav bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancel"))
        
        // Add the subviews
        self.view.backgroundColor = themeBackgroundColor
        self.loadLinkTextField()
        self.loadVideoInfo()
        
        // Touch anywhere to dismiss keyboard
        let tapDismiss:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapDismiss)
        
        // Check if user already has a youtube share link copied
        if let copyString = UIPasteboard.generalPasteboard().string {
            if copyString.rangeOfString("youtu.be/") != nil {
                self.youtubeLinkField.text = copyString
                self.youtubeLinkField.hidden = true
                self.checkLinkButton.hidden = true
                self.copyDetected()
            }
        }
        
    }
    
    // Function to dismiss keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // add a upload button after loading info from youtube
    func loadButton() {
        uploadButton.roundBackgroundColor = UIColor(rgba: "#2ABB9B")
        uploadButton.lineThickness = 2
        uploadButton.tintColor = UIColor.whiteColor()
        self.view.addSubview(uploadButton)
        uploadButton.addTarget(self, action: Selector("checkLink"), forControlEvents: .TouchUpInside)
        
        uploadButton.autoAlignAxisToSuperviewAxis(.Vertical)
        uploadButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: videoContainer, withOffset: 20)
    }
    
    // 0: If user has a youtube link in pasteboard
    // Use alert view to ask for video info
    func copyDetected() {
        self.loadButton()
    }
    
    // 1: Show the text field for user to input youtube link
    func loadLinkTextField() {
        // Add the textfield as subview
        youtubeLinkField.delegate = self
        youtubeLinkField.font = UIFont.systemFontOfSize(18)
        youtubeLinkField.backgroundColor = UIColor.clearColor()
        youtubeLinkField.placeholder = "Please paste youtube link here"
        self.view.addSubview(youtubeLinkField)
        youtubeLinkField.autoPinToTopLayoutGuideOfViewController(self, withInset: 10)
        youtubeLinkField.autoPinEdgeToSuperviewEdge(.Leading, withInset: 5)
        
        checkLinkButton.setTitle(" Done ", forState: .Normal)
        self.view.addSubview(checkLinkButton)
        checkLinkButton.enabled = true
        checkLinkButton.autoAlignAxis(.Horizontal, toSameAxisOfView: youtubeLinkField)
        checkLinkButton.autoMatchDimension(.Height, toDimension: .Height, ofView: youtubeLinkField, withMultiplier: 0.9)
        checkLinkButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 5)
        youtubeLinkField.autoPinEdge(.Right, toEdge: .Left, ofView: checkLinkButton, withOffset: -5)
        
    }
    
    func checkLink() {
        self.dismissKeyboard()
        if self.youtubeLinkField.text?.characters.count >= 26 {
            let videoID = self.youtubeLinkField.text?.substringFromIndex(self.youtubeLinkField.text!.endIndex.advancedBy(-11))
            self.getYoutubeVideoData(videoID)
        }
    }
    
    // 2: Display video info if successfully getched from youtube
    func loadVideoInfo() {
        let containerHeight = UIScreen.mainScreen().bounds.size.height/1.8
        let containerWidth = UIScreen.mainScreen().bounds.size.width - 10
        videoContainer.layer.borderColor = UIColor.clearColor().CGColor
        videoContainer.layer.borderWidth = 1
        videoContainer.layer.cornerRadius = 5
        videoContainer.backgroundColor = UIColor.clearColor()
        self.view.addSubview(videoContainer)
        videoContainer.autoSetDimension(.Height, toSize: containerHeight)
        videoContainer.autoSetDimension(.Width, toSize: containerWidth)
        videoContainer.autoAlignAxisToSuperviewAxis(.Vertical)
        videoContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: checkLinkButton, withOffset: 10)
        
        let categoryImageSize:CGFloat = 30
        categoryImage.autoSetDimensionsToSize(CGSize(width: categoryImageSize, height: categoryImageSize))
        categoryImage.backgroundColor = UIColor.clearColor()
        categoryImage.layer.borderWidth = 0.1
        categoryImage.layer.masksToBounds = true
        categoryImage.layer.borderColor = UIColor.clearColor().CGColor
        categoryImage.layer.cornerRadius = categoryImageSize/2
        categoryImage.clipsToBounds = true
        
        categoryName.font = UIFont.boldSystemFontOfSize(10)
        categoryName.morphingEffect = .Pixelate
        categoryName.text = " "
        categoryName.sizeToFit()
        
        thumbnailImage.contentMode = .ScaleAspectFill
        thumbnailImage.clipsToBounds = true
        
        videoTitle.lineBreakMode = .ByTruncatingTail
        videoTitle.morphingEffect = .Pixelate
        videoTitle.text = "Looks like you copied a Youtube link?"
        videoTitle.numberOfLines = 2
        videoTitle.textAlignment = .Center
        videoTitle.textColor = UIColor.blackColor()
        videoTitle.font = UIFont.boldSystemFontOfSize(12)
        videoTitle.sizeToFit()
        
        videoContainer.addSubview(topView)
        videoContainer.addSubview(bottomView)
        topView.addSubview(categoryImage)
        topView.addSubview(categoryName)
        videoContainer.addSubview(thumbnailImage)
        bottomView.addSubview(videoTitle)
        
        topView.autoSetDimension(.Height, toSize: 35)
        topView.autoPinEdgeToSuperviewEdge(.Top)
        topView.autoPinEdgeToSuperviewEdge(.Leading)
        topView.autoPinEdgeToSuperviewEdge(.Trailing)
        
        categoryImage.autoAlignAxisToSuperviewAxis(.Horizontal)
        categoryImage.autoPinEdgeToSuperviewEdge(.Leading, withInset: 5)
        
        categoryName.autoAlignAxis(.Horizontal, toSameAxisOfView: categoryImage)
        categoryName.autoPinEdge(.Leading, toEdge: .Trailing, ofView: categoryImage, withOffset: 5)
        categoryName.autoPinEdgeToSuperviewEdge(.Trailing)
        
        thumbnailImage.autoPinEdge(.Top, toEdge: .Bottom, ofView: topView)
        thumbnailImage.autoPinEdgeToSuperviewEdge(.Leading)
        thumbnailImage.autoPinEdgeToSuperviewEdge(.Trailing)
        thumbnailImage.autoMatchDimension(.Height, toDimension: .Width, ofView: videoContainer, withMultiplier: 0.75)
        
        bottomView.autoPinEdge(.Top, toEdge: .Bottom, ofView: thumbnailImage)
        bottomView.autoPinEdgeToSuperviewEdge(.Leading)
        bottomView.autoPinEdgeToSuperviewEdge(.Trailing)
        bottomView.autoPinEdgeToSuperviewEdge(.Bottom)
        
        videoTitle.autoPinEdgeToSuperviewEdge(.Left)
        videoTitle.autoPinEdgeToSuperviewEdge(.Right)
        videoTitle.autoPinEdgeToSuperviewEdge(.Top)
        videoTitle.autoPinEdgeToSuperviewEdge(.Bottom)
        videoTitle.clipsToBounds = true
    }
    
    
    // Utelize youtube api to fetch desired info about video
    func getYoutubeVideoData(videoId: String!) {
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/videos?key=\(googleApiKey)&part=snippet,statistics&id=\(videoId)")
            .responseJSON { response in
                print(response.request)
                if let JSON = response.result.value {
                    // Get the first video item
                    // Usually there is only one video item returned
                    if let items: AnyObject = JSON["items"] as? Array<AnyObject> {
                        if items.count > 0 {
                            self.getVideoInfo(items as! Array<AnyObject>)
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
                    if let items: AnyObject = JSON["items"] as? Array<AnyObject> {
                        if items.count > 0 {
                            self.getChannelInfo(items as! Array<AnyObject>)
                        } else {
                            print("No item returned from youtube")
                        }
                    }
                    // End of getting the first channel item
                }
        }
    }
    func getVideoCommentsData(videoId: String) {
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/commentThreads?key=\(googleApiKey)&textFormat=plainText&part=snippet&videoId=\(videoId)&maxResults=20")
            .responseJSON { response in
                if let JSON = response.result.value {
                    if let items: AnyObject = JSON["items"] as? Array<AnyObject> {
                        if items.count > 0 {
                            self.getCommentsInfo(items as! Array<AnyObject>)
                        } else {
                            print("No comments returned")
                        }
                    }
                }
        }
    }
    // Use this function to retrieve desired info about this youtube video
    func getVideoInfo(items: Array<AnyObject>) {
        if let firstItemDict: Dictionary<NSObject, AnyObject> = items[0] as? Dictionary<NSObject, AnyObject> {
            if let snippetDict: Dictionary<NSObject, AnyObject> = firstItemDict["snippet"] as? Dictionary<NSObject, AnyObject> {
                if let thumbnailsDict: Dictionary<NSObject, AnyObject> = snippetDict["thumbnails"] as? Dictionary<NSObject, AnyObject> {
                    self.youtubeIDParse = firstItemDict["id"] as! String
                    self.videoTitleParse = snippetDict["title"] as! String
                    self.videoTitle.textAlignment = .Left
                    self.videoTitle.font = UIFont.systemFontOfSize(16)
                    self.videoTitle.text = snippetDict["title"] as? String
                    self.videoDescParse = snippetDict["description"] as! String
                    self.channelIdParse = snippetDict["channelId"] as! String
                    if let channelId: String = snippetDict["channelId"] as? String {
                        self.getYoutubeChanelData(channelId)
                        self.checkParseChannel(channelId)
                        self.channelIdParse = channelId
                    }
                    self.channelTitleParse = snippetDict["channelTitle"] as! String
                    if let defaultUrl = thumbnailsDict["default"]?["url"] as? String {
                        self.defaultImageParse = defaultUrl
                        self.thumbnailImage.sd_setImageWithURL(NSURL(string: defaultUrl))
                    }
                    if let stadUrl = thumbnailsDict["standard"]?["url"] as? String {
                        self.standardImageParse = stadUrl
                        self.thumbnailImage.sd_setImageWithURL(NSURL(string: stadUrl))
                    }
                    self.videoContainer.backgroundColor = UIColor.whiteColor()
                    self.uploadButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                    self.uploadButton.addTarget(self, action: Selector("checkParseVideo"), forControlEvents: .TouchUpInside)
                    self.uploadButton.animateToType(.buttonAddType)
                    // Getting statistics
                    if let statDict: Dictionary<NSObject, AnyObject> = firstItemDict["statistics"] as? Dictionary<NSObject, AnyObject> {
                        self.viewCountParse = Int(statDict["viewCount"] as! String)!
                        if Int(statDict["viewCount"] as! String)! >= 500000 {
                            self.reviewPassedParse = true
                        }
                    } else {
                        print("Error: getting stat info")
                    }
                    // End of getting statistics
                }
            }
        }
    }
    // End of getting video info from youtube
    
    // Use this function to retrieve desired info about this channel
    func getChannelInfo(items: Array<AnyObject>) {
        if let firstItemDict: Dictionary<NSObject, AnyObject> = items[0] as? Dictionary<NSObject, AnyObject> {
            // Getting snippet
            if let snippetDict: Dictionary<NSObject, AnyObject> = firstItemDict["snippet"] as? Dictionary<NSObject, AnyObject> {
                if let catName: String = snippetDict["title"] as? String {
                    self.categoryName.text = catName
                }
                if let thumbnailsDict: Dictionary<NSObject, AnyObject> = snippetDict["thumbnails"] as? Dictionary<NSObject, AnyObject> {
                    if let defaultUrl: String = thumbnailsDict["default"]?["url"] as? String {
                        self.categoryImage.sd_setImageWithURL(NSURL(string: defaultUrl))
                        self.channelImageParse = defaultUrl
                    }
                }
            } else {
                print("Error: Getting snippet item")
            }
            // End of getting snippet
        } else {
            print("Error: getting first item")
        }
    }
    // End of retrieving channel info
    
    // Get comments from the youtube video
    func getCommentsInfo(items: Array<AnyObject>) {
        
    }
    // End of getting youtube comments
    
// End of using youtube api
    
    func checkParseChannel(channelId: String!) {
        let query = PFQuery(className: "YoutubeChannel")
        query.whereKey("channelId", equalTo: channelId)
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if object != nil {
                // The associated channel is already passed by Parse
                self.reviewPassedParse = true
            }
        }
    }
    
    func checkParseVideo() {
        self.uploadButton.animateToType(FlatButtonType.buttonShareType)
        self.uploadButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        self.uploadButton.addTarget(self, action: Selector("cancel"), forControlEvents: .TouchUpInside)
        if self.videoSaved == false {
            // Check if this youtube video is already saved to Parse
            let query = PFQuery(className: "YoutubeVideo")
            query.whereKey("youtubeId", equalTo: self.youtubeIDParse)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error != nil || object == nil {
                    print("This video is new to Parse.")
                    let savingVideo:PFObject = PFObject(className: "YoutubeVideo")
                    self.saveParse(savingVideo)
                } else if let object = object {
                    // The find succeeded.
                    // There is already this youtube video in the database
                    self.videoSaved = true
                    self.savedObjectId = object.objectId!
                    self.saveParse(object)
                    print("Already has video in stock.")
                }
                
            }
            // End of checking
        }
    }
    
    func saveParse(savingVideo: PFObject!) {
        if self.videoSaved == false {
            savingVideo["channelId"] = self.channelIdParse
            savingVideo["channelTitle"] = self.channelTitleParse
            savingVideo["channelImage"] = self.channelImageParse
            savingVideo["defaultImageUrl"] = self.defaultImageParse
            savingVideo["standardImageUrl"] = self.standardImageParse
            savingVideo["videoTitle"] = self.videoTitleParse
            savingVideo["videoDesc"] = self.videoDescParse
            savingVideo["viewCount"] = self.viewCountParse
            savingVideo["youtubeId"] = self.youtubeIDParse
            savingVideo["reviewPassed"] = self.reviewPassedParse
            savingVideo.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if success {
                    // The new video is successfully saved to Parse
                    self.videoSaved = true
                    self.savedObjectId = savingVideo.objectId!
                    self.getVideoCommentsData(self.youtubeIDParse)
                } else {
                    // Error during saving new video to Parse
                }
            }
        } else {
            print("Already saved video, no need to do anything")
        }
        self.endAnimation()
    }
    
    func endAnimation() {
        
        UIView.animateWithDuration(3.0, delay: 0.0, options: .BeginFromCurrentState, animations: {
            self.topView.removeFromSuperview()
            self.bottomView.removeFromSuperview()
            self.thumbnailImage.removeFromSuperview()

            self.videoContainer.backgroundColor = sideMenuColor
            for const in self.videoContainer.constraints {
                self.videoContainer.removeConstraint(const)
            }
            self.videoContainer.autoPinToTopLayoutGuideOfViewController(self, withInset: 30)
            self.videoContainer.autoSetDimension(.Height, toSize: 0)
            self.videoContainer.autoSetDimension(.Width, toSize: 0)
            self.videoContainer.layoutIfNeeded()
            self.view.layoutIfNeeded()
            }, completion: {(Bool) in
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                self.uploadButton.lineThickness = 5
                self.uploadButton.animateToType(FlatButtonType.buttonOkType)
                let savingDoneBar = TTGSnackbar(message: "Your video is saved successfully, Thanks", duration: .Long)
                savingDoneBar.messageTextColor = UIColor.whiteColor()
                savingDoneBar.show()
        })
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
