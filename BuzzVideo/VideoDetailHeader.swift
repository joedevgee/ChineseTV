//
//  VideoDetailHeader.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/18/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import UIColor_Hex_Swift
import FontAwesomeKit
import LTMorphingLabel

class VideoDetailHeader: UITableViewCell {
    
    let playerHeight:CGFloat = UIScreen.mainScreen().bounds.size.width*0.57
    
    var didSetupConstraints = false
    var playerContainer:UIView = UIView.newAutoLayoutView()
    var socialContainer:UIView = UIView.newAutoLayoutView()
    
    var channelTitle:LTMorphingLabel = LTMorphingLabel.newAutoLayoutView()
    
    let socialIconSize:CGFloat = 30
    var facebookLabel:UILabel = UILabel.newAutoLayoutView()
    var twitterLabel:UILabel = UILabel.newAutoLayoutView()
    var weixinLabel:UILabel = UILabel.newAutoLayoutView()
    var replyLabel:UILabel = UILabel.newAutoLayoutView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        
        contentView.backgroundColor = UIColor.blackColor()
        
        playerContainer.backgroundColor = UIColor.blackColor()
        socialContainer.backgroundColor = UIColor.whiteColor()
        
        socialContainer.layer.borderWidth = 2
        socialContainer.layer.borderColor = themeBackgroundColor.CGColor
        
        channelTitle.font = UIFont.boldSystemFontOfSize(12)
        channelTitle.text = "Original Source"
        channelTitle.textAlignment = .Center
        channelTitle.numberOfLines = 1
        channelTitle.morphingEffect = .Scale
        channelTitle.lineBreakMode = .ByTruncatingTail
        channelTitle.text = "    "
        channelTitle.sizeToFit()
        
        let facebookIcon = FAKFontAwesome.facebookIconWithSize(socialIconSize)
        facebookIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        facebookLabel.attributedText = facebookIcon.attributedString()
        facebookLabel.backgroundColor = facebookColor
        facebookLabel.textAlignment = .Center
        
        let twitterIcon = FAKFontAwesome.twitterIconWithSize(socialIconSize)
        twitterIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        twitterLabel.attributedText = twitterIcon.attributedString()
        twitterLabel.backgroundColor = twitterColor
        twitterLabel.textAlignment = .Center
        
        let weixinIcon = FAKFontAwesome.weixinIconWithSize(socialIconSize)
        weixinIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        weixinLabel.attributedText = weixinIcon.attributedString()
        weixinLabel.backgroundColor = weixinColor
        weixinLabel.textAlignment = .Center
        
        let replyIcon = FAKFontAwesome.replyIconWithSize(socialIconSize)
        replyIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        replyLabel.attributedText = replyIcon.attributedString()
        replyLabel.backgroundColor = sideMenuColor
        replyLabel.textAlignment = .Center
        
        contentView.addSubview(playerContainer)
        contentView.addSubview(socialContainer)
        socialContainer.addSubview(channelTitle)
        socialContainer.addSubview(facebookLabel)
        socialContainer.addSubview(twitterLabel)
        socialContainer.addSubview(weixinLabel)
        socialContainer.addSubview(replyLabel)
    }
    
    override func updateConstraints() {
        if !self.didSetupConstraints {
            
            contentView.bounds = CGRect(x: 0.0, y: 0.0, width: 99999.0, height: 99999.0)
            
            playerContainer.autoSetDimension(.Height, toSize: self.playerHeight)
            playerContainer.autoPinEdgeToSuperviewEdge(.Top)
            playerContainer.autoPinEdgeToSuperviewEdge(.Left)
            playerContainer.autoPinEdgeToSuperviewEdge(.Right)
            
            socialContainer.autoPinEdgeToSuperviewEdge(.Left, withInset: -2)
            socialContainer.autoPinEdgeToSuperviewEdge(.Right, withInset: -2)
            socialContainer.autoPinEdgeToSuperviewEdge(.Bottom)
            socialContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: playerContainer)
            
            replyLabel.autoMatchDimension(.Width, toDimension: .Height, ofView: socialContainer)
            replyLabel.autoPinEdgeToSuperviewEdge(.Top)
            replyLabel.autoPinEdgeToSuperviewEdge(.Right)
            replyLabel.autoPinEdgeToSuperviewEdge(.Bottom)
            
            weixinLabel.autoMatchDimension(.Width, toDimension: .Height, ofView: socialContainer)
            weixinLabel.autoPinEdge(.Right, toEdge: .Left, ofView: replyLabel)
            weixinLabel.autoPinEdgeToSuperviewEdge(.Top)
            weixinLabel.autoPinEdgeToSuperviewEdge(.Bottom)
            
            twitterLabel.autoMatchDimension(.Width, toDimension: .Height, ofView: socialContainer)
            twitterLabel.autoPinEdge(.Right, toEdge: .Left, ofView: weixinLabel)
            twitterLabel.autoPinEdgeToSuperviewEdge(.Top)
            twitterLabel.autoPinEdgeToSuperviewEdge(.Bottom)
            
            facebookLabel.autoMatchDimension(.Width, toDimension: .Height, ofView: socialContainer)
            facebookLabel.autoPinEdge(.Right, toEdge: .Left, ofView: twitterLabel)
            facebookLabel.autoPinEdgeToSuperviewEdge(.Top)
            facebookLabel.autoPinEdgeToSuperviewEdge(.Bottom)
            
            channelTitle.autoPinEdgeToSuperviewEdge(.Top)
            channelTitle.autoPinEdgeToSuperviewEdge(.Left)
            channelTitle.autoPinEdgeToSuperviewEdge(.Bottom)
            channelTitle.autoPinEdge(.Right, toEdge: .Left, ofView: facebookLabel, withOffset: 5, relation: NSLayoutRelation.GreaterThanOrEqual)
//            channelTitle.autoPinEdge(.Right, toEdge: .Left, ofView: facebookLabel, withOffset: 5)
            
            self.didSetupConstraints = true
        }
        super.updateConstraints()
    }


}
