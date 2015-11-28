//
//  LeftMenuTableViewCell.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/22/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout

class LeftMenuTableViewCell: UITableViewCell {
    
    let rowHeight:CGFloat = UIScreen.mainScreen().bounds.size.height/6
    
    var didSetupConstraints = false
    
    var mainContainer:UIView = UIView.newAutoLayoutView()
    var playlistImageView:UIImageView = UIImageView.newAutoLayoutView()
    var playlistName:UILabel = UILabel.newAutoLayoutView()
    var progressInfo:UILabel = UILabel.newAutoLayoutView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        contentView.backgroundColor = themeColor
        
        mainContainer.backgroundColor = themeColor
        mainContainer.layer.borderColor = themeColor.CGColor
        
        playlistImageView.contentMode = .Center
        let imageHeight:CGFloat = rowHeight*0.5
        playlistImageView.autoSetDimensionsToSize(CGSizeMake(imageHeight, imageHeight))
        playlistImageView.layer.masksToBounds = true
        playlistImageView.layer.borderColor = UIColor.clearColor().CGColor
        playlistImageView.layer.cornerRadius = imageHeight*0.5
        playlistImageView.clipsToBounds = true
        
        playlistName.text = ""
        playlistName.textColor = UIColor.whiteColor()
        playlistName.numberOfLines = 1
        playlistName.textAlignment = .Left
        playlistName.font = UIFont.boldSystemFontOfSize(12)
        playlistName.sizeToFit()
        
        progressInfo.text = ""
        progressInfo.textColor = UIColor.whiteColor()
        progressInfo.textAlignment = .Left
        progressInfo.numberOfLines = 2
        progressInfo.font = UIFont.systemFontOfSize(8)
        progressInfo.sizeToFit()
        
        contentView.addSubview(mainContainer)
        mainContainer.addSubview(playlistImageView)
        mainContainer.addSubview(playlistName)
        mainContainer.addSubview(progressInfo)
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
            mainContainer.autoPinEdgeToSuperviewEdge(.Left)
            mainContainer.autoPinEdgeToSuperviewEdge(.Top)
            mainContainer.autoPinEdgeToSuperviewEdge(.Bottom)
            mainContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: contentView, withMultiplier: 0.5)
            
            playlistImageView.autoAlignAxisToSuperviewAxis(.Horizontal)
            playlistImageView.autoPinEdgeToSuperviewEdge(.Left, withInset: 0)
            
            playlistName.autoPinEdge(.Left, toEdge: .Right, ofView: playlistImageView, withOffset: 5)
            playlistName.autoPinEdgeToSuperviewEdge(.Right, withInset: 5)
            playlistName.autoAlignAxis(.Horizontal, toSameAxisOfView: playlistImageView, withOffset: -10)
            
            progressInfo.autoPinEdge(.Left, toEdge: .Right, ofView: playlistImageView, withOffset: 5)
            progressInfo.autoAlignAxis(.Horizontal, toSameAxisOfView: playlistImageView, withOffset: 10)
            progressInfo.autoPinEdgeToSuperviewEdge(.Right, withInset: 5)
            progressInfo.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5)
            
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
}


