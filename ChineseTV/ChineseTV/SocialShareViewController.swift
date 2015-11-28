//
//  SocialShareViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/19/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import SDWebImage
import FBSDKCoreKit
import FBSDKShareKit
import FontAwesomeKit

let socialViewSize:CGSize = CGSize(width: UIScreen.mainScreen().bounds.width*0.8, height: UIScreen.mainScreen().bounds.height*0.6)

class SocialShareViewController: UIViewController {
    
    var shareVideo:Video?
    
    var mainContainer:UIView = UIView.newAutoLayoutView()
    var topLabel:UILabel = UILabel.newAutoLayoutView()
    var middleView:UIImageView = UIImageView.newAutoLayoutView()
    var defaultImageView:UIImageView = UIImageView.newAutoLayoutView()
    var bottomView:UIView = UIView.newAutoLayoutView()
    
    var firstButton:UIView = UIView.newAutoLayoutView()
    var secondButton:UIView = UIView.newAutoLayoutView()
    var thirdButton:UIView = UIView.newAutoLayoutView()
    var forthButton:UIView = UIView.newAutoLayoutView()

    
    var fbShareButton:UIButton = UIButton.newAutoLayoutView()
    var fbLabel:UILabel = UILabel.newAutoLayoutView()
    var wechatShareButton:UIButton = UIButton.newAutoLayoutView()
    var wechatLabel:UILabel = UILabel.newAutoLayoutView()
    var qqShareButton:UIButton = UIButton.newAutoLayoutView()
    var qqLabel:UILabel = UILabel.newAutoLayoutView()
    var weixinShareButton:UIButton = UIButton.newAutoLayoutView()
    var weixinLabel:UILabel = UILabel.newAutoLayoutView()
    
    var closeButton:UIButton = UIButton.newAutoLayoutView()
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        
        self.view.backgroundColor = UIColor.clearColor()
        mainContainer.backgroundColor = UIColor.clearColor()
        topLabel.backgroundColor = UIColor.clearColor()
        middleView.backgroundColor = UIColor.clearColor()
        bottomView.backgroundColor = UIColor.clearColor()
        
        middleView.contentMode = .ScaleAspectFit
        
        closeButton.addTarget(self, action: "closeView", forControlEvents: .TouchUpInside)
        let closeIcon:FAKFontAwesome = FAKFontAwesome.closeIconWithSize(20)
        closeIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        closeIcon.drawingBackgroundColor = UIColor.clearColor()
        let closeImage:UIImage = closeIcon.imageWithSize(CGSize(width: 20, height: 20))
        closeButton.setImage(closeImage, forState: .Normal)
        
        topLabel.font = UIFont.boldSystemFontOfSize(25)
        topLabel.numberOfLines = 1
        topLabel.textColor = UIColor.whiteColor()
        topLabel.textAlignment = .Center
        topLabel.text = "分享给好友"
        
        let buttonSize:CGSize = CGSize(width: UIScreen.mainScreen().bounds.width/8, height: UIScreen.mainScreen().bounds.width/8)
        let iconSize:CGFloat = buttonSize.width*0.6
        let buttonLabelSize:CGFloat = 8
        
        let fbIcon:FAKFontAwesome = FAKFontAwesome.facebookIconWithSize(iconSize)
        fbIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        fbIcon.drawingBackgroundColor = UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1)
        let fbImage:UIImage = fbIcon.imageWithSize(buttonSize)
        fbShareButton.setImage(fbImage, forState: .Normal)
        fbShareButton.addTarget(self, action: "shareToFacebook", forControlEvents: .TouchUpInside)
        fbShareButton.layer.masksToBounds = true
        fbShareButton.layer.cornerRadius = buttonSize.width/2
        fbShareButton.clipsToBounds = true
        
        fbLabel.text = "Facebook"
        fbLabel.textColor = UIColor.whiteColor()
        fbLabel.textAlignment = .Center
        fbLabel.font = UIFont.boldSystemFontOfSize(buttonLabelSize)
        
        let wechatIcon:FAKFontAwesome = FAKFontAwesome.wechatIconWithSize(iconSize)
        wechatIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        wechatIcon.drawingBackgroundColor = UIColor(red: 123/255, green: 179/255, blue: 46/255, alpha: 1)
        let wechatImage:UIImage = wechatIcon.imageWithSize(buttonSize)
        wechatShareButton.setImage(wechatImage, forState: .Normal)
        wechatShareButton.addTarget(self, action: "shareToWechat", forControlEvents: .TouchUpInside)
        wechatShareButton.layer.masksToBounds = true
        wechatShareButton.layer.cornerRadius = buttonSize.width/2
        wechatShareButton.clipsToBounds = true
        
        wechatLabel.text = "微信好友"
        wechatLabel.textColor = UIColor.whiteColor()
        wechatLabel.textAlignment = .Center
        wechatLabel.font = UIFont.boldSystemFontOfSize(buttonLabelSize)
        
        let weixinImage:UIImage = UIImage(named: "weixin.png")!
        weixinShareButton.autoSetDimensionsToSize(buttonSize)
        weixinShareButton.setImage(weixinImage, forState: .Normal)
        weixinShareButton.layer.masksToBounds = true
        weixinShareButton.layer.cornerRadius = buttonSize.width/2
        weixinShareButton.clipsToBounds = true
        weixinShareButton.backgroundColor = UIColor.whiteColor()
        weixinShareButton.addTarget(self, action: "shareToWeixin", forControlEvents: .TouchUpInside)
        
        weixinLabel.text = "朋友圈"
        weixinLabel.textColor = UIColor.whiteColor()
        weixinLabel.textAlignment = .Center
        weixinLabel.font = UIFont.boldSystemFontOfSize(buttonLabelSize)
        
        let qqIcon:FAKFontAwesome = FAKFontAwesome.qqIconWithSize(iconSize)
        qqIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        qqIcon.drawingBackgroundColor = UIColor(red: 64/255, green: 153/255, blue: 255/255, alpha: 1)
        let qqImage:UIImage = qqIcon.imageWithSize(buttonSize)
        qqShareButton.setImage(qqImage, forState: .Normal)
        qqShareButton.addTarget(self, action: "shareToQq", forControlEvents: .TouchUpInside)
        qqShareButton.layer.masksToBounds = true
        qqShareButton.layer.cornerRadius = buttonSize.width/2
        qqShareButton.clipsToBounds = true
        
        qqLabel.text = "QQ"
        qqLabel.textColor = UIColor.whiteColor()
        qqLabel.textAlignment = .Center
        qqLabel.font = UIFont.boldSystemFontOfSize(buttonLabelSize)
        
        self.view.addSubview(mainContainer)
        mainContainer.addSubview(closeButton)
        mainContainer.addSubview(topLabel)
        mainContainer.addSubview(middleView)
        mainContainer.addSubview(bottomView)
        
        mainContainer.autoPinEdgeToSuperviewEdge(.Top)
        mainContainer.autoPinEdgeToSuperviewEdge(.Left)
        mainContainer.autoSetDimensionsToSize(socialViewSize)
        
        closeButton.autoAlignAxisToSuperviewAxis(.Vertical)
        closeButton.autoPinEdgeToSuperviewEdge(.Top)
        
        topLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: closeButton, withOffset: 10)
        topLabel.autoPinEdgeToSuperviewEdge(.Left)
        topLabel.autoPinEdgeToSuperviewEdge(.Right)
        
        middleView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topLabel, withOffset: 2, relation: .LessThanOrEqual)
        middleView.autoPinEdgeToSuperviewEdge(.Left)
        middleView.autoPinEdgeToSuperviewEdge(.Right)
        middleView.autoMatchDimension(.Height, toDimension: .Height, ofView: mainContainer, withMultiplier: 0.5)
        
        bottomView.autoPinEdge(.Top, toEdge: .Bottom, ofView: middleView, withOffset: 2, relation: .GreaterThanOrEqual)
        bottomView.autoPinEdgeToSuperviewEdge(.Left)
        bottomView.autoPinEdgeToSuperviewEdge(.Right)
        bottomView.autoPinEdgeToSuperviewEdge(.Bottom)
        
        let centerPlaceholder:UILabel = UILabel.newAutoLayoutView()
        centerPlaceholder.text = ""
        
        bottomView.addSubview(centerPlaceholder)
        centerPlaceholder.autoCenterInSuperview()
        
        bottomView.addSubview(fbShareButton)
        bottomView.addSubview(fbLabel)
        bottomView.addSubview(wechatShareButton)
        bottomView.addSubview(wechatLabel)
        bottomView.addSubview(weixinShareButton)
        bottomView.addSubview(weixinLabel)
        bottomView.addSubview(qqShareButton)
        bottomView.addSubview(qqLabel)
        
        fbShareButton.autoPinEdge(.Right, toEdge: .Left, ofView: centerPlaceholder, withOffset: -10)
        fbShareButton.autoPinEdgeToSuperviewEdge(.Top)
        
        fbLabel.autoAlignAxis(.Vertical, toSameAxisOfView: fbShareButton)
        fbLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: fbShareButton, withOffset: 2, relation: .GreaterThanOrEqual)
        
        wechatShareButton.autoPinEdge(.Left, toEdge: .Right, ofView: centerPlaceholder, withOffset: 10)
        wechatShareButton.autoPinEdgeToSuperviewEdge(.Top)
        
        wechatLabel.autoAlignAxis(.Vertical, toSameAxisOfView: wechatShareButton)
        wechatLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: wechatShareButton, withOffset: 2, relation: .GreaterThanOrEqual)
        
        qqShareButton.autoPinEdge(.Right, toEdge: .Left, ofView: fbShareButton, withOffset: -20)
        qqShareButton.autoPinEdgeToSuperviewEdge(.Top)
        
        qqLabel.autoAlignAxis(.Vertical, toSameAxisOfView: qqShareButton)
        qqLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: qqShareButton, withOffset: 2, relation: .GreaterThanOrEqual)
        
        weixinShareButton.autoPinEdge(.Left, toEdge: .Right, ofView: wechatShareButton, withOffset: 20)
        weixinShareButton.autoAlignAxis(.Horizontal, toSameAxisOfView: wechatShareButton)
        
        weixinLabel.autoAlignAxis(.Vertical, toSameAxisOfView: weixinShareButton)
        weixinLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: weixinShareButton, withOffset: 2, relation: .GreaterThanOrEqual)
    }
    
    func loadVideoInfo(video:Video) {
        self.middleView.sd_setImageWithURL(NSURL(string: video.shareImageUrl))
        self.defaultImageView.sd_setImageWithURL(NSURL(string: video.thumbnailUrl))
    }
    
    func shareToFacebook() {
        let msg = FBSDKShareLinkContent()
        msg.contentURL = NSURL(string: "https://www.google.com")
        msg.contentTitle = self.shareVideo?.name
        msg.imageURL = NSURL(string: (self.shareVideo?.shareImageUrl)!)
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = msg
        dialog.mode = FBSDKShareDialogMode.ShareSheet
        dialog.show()
    }
    
    // Share to wechat friends
    func shareToWechat() {
        let msg:Message = Message()
        msg.title = self.shareVideo?.name
        if let shareImage:UIImage = self.defaultImageView.image {
            msg.image = UIImageJPEGRepresentation(shareImage, 1)
        }
        msg.link = "https://www.google.com"
        if let share = ShareManager.getShare(domain: RSWeChat.domain) as? RSWeChat {
            share.shareToWeChatSession(msg, success: { message in print("Success")}, fail: { message, error in print("fail")})
        }
    }
    
    // Share to wechat timeline
    func shareToWeixin() {
        let msg:Message = Message()
        msg.title = self.shareVideo?.name
        if let shareImage:UIImage = self.defaultImageView.image {
            msg.image = UIImageJPEGRepresentation(shareImage, 1)
        }
        msg.link = "https://www.google.com"
        if let share = ShareManager.getShare(domain: RSWeChat.domain) as? RSWeChat {
            share.shareToWeChatTimeline(msg, success: { message in print("Success")}, fail: { message, error in print("fail")})
        }
    }
    
    
    //TODO: get through with qq share process
    func shareToQq() {
        let msg:Message = Message()
        msg.title = self.shareVideo?.name
        if let shareImage:UIImage = self.defaultImageView.image {
            msg.image = UIImageJPEGRepresentation(shareImage, 1)
            msg.thumbnail = msg.image
            msg.desc = "这里写的是msg.description"
        }
        msg.link = "https://www.google.com"
        if let share = ShareManager.getShare(domain: RSQQ.domain) as? RSQQ {
            share.shareToQQFriends(msg,
                success: { message in print("success")},
                fail: { message, error in
                    print("fail")
                    print(error)
                }
            )
        }
    }

}