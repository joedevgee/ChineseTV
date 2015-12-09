//
//  MainTableViewCell.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/9/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import ParseUI
import FontAwesomeKit

class MainTableViewCell: PFTableViewCell {
    
    var didSetupConstraints = false
    var mainContainer:UIView = UIView.newAutoLayoutView()
    var topView:UIView = UIView.newAutoLayoutView()
    var middleView:UIView = UIView.newAutoLayoutView()
    var bottomView:UIView = UIView.newAutoLayoutView()
    var footerView:UIView = UIView.newAutoLayoutView()
    var listSubtitle:UILabel = UILabel.newAutoLayoutView()
    var viewImage:UIImageView = UIImageView.newAutoLayoutView()
    var viewCounts:UILabel = UILabel.newAutoLayoutView()
    var thumbnailImage:UIImageView = UIImageView.newAutoLayoutView()
    var listTitle:UILabel = UILabel.newAutoLayoutView()
    var footerImageView:UIImageView = UIImageView.newAutoLayoutView()
    var footerLabel:UILabel = UILabel.newAutoLayoutView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        
        listSubtitle.font = UIFont.systemFontOfSize(10)
        listSubtitle.sizeToFit()
        
        thumbnailImage.contentMode = .ScaleAspectFill
        thumbnailImage.clipsToBounds = true
        
        listTitle.lineBreakMode = .ByTruncatingTail
        listTitle.numberOfLines = 2
        listTitle.textAlignment = .Left
        listTitle.textColor = UIColor.blackColor()
        listTitle.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        listTitle.sizeToFit()
        
        mainContainer.backgroundColor = UIColor.whiteColor()
        mainContainer.layer.cornerRadius = 5
        contentView.backgroundColor = dividerColor
        
        contentView.addSubview(mainContainer)
        mainContainer.addSubview(topView)
        topView.addSubview(listSubtitle)
        mainContainer.addSubview(middleView)
        middleView.addSubview(thumbnailImage)
        mainContainer.addSubview(bottomView)
        bottomView.addSubview(listTitle)
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
            mainContainer.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 5, left: 6, bottom: 5, right: 6))
            
            topView.autoMatchDimension(.Height, toDimension: .Height, ofView: mainContainer, withMultiplier: 0.10)
            topView.autoPinEdgeToSuperviewEdge(.Top)
            topView.autoPinEdgeToSuperviewEdge(.Leading)
            topView.autoPinEdgeToSuperviewEdge(.Trailing)
            
            listSubtitle.autoAlignAxisToSuperviewAxis(.Horizontal)
            listSubtitle.autoPinEdgeToSuperviewEdge(.Leading, withInset: 5)
            
            middleView.autoMatchDimension(.Height, toDimension: .Height, ofView: mainContainer, withMultiplier: 0.65)
            middleView.autoPinEdgeToSuperviewEdge(.Leading)
            middleView.autoPinEdgeToSuperviewEdge(.Trailing)
            middleView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topView)
            
            thumbnailImage.autoPinEdgesToSuperviewEdges()
            
            bottomView.autoPinEdge(.Top, toEdge: .Bottom, ofView: middleView)
            bottomView.autoPinEdgeToSuperviewEdge(.Leading)
            bottomView.autoPinEdgeToSuperviewEdge(.Trailing)
            bottomView.autoPinEdgeToSuperviewEdge(.Bottom)
            
            listTitle.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
            
//            footerView.autoPinEdge(.Top, toEdge: .Bottom, ofView: bottomView)
//            footerView.autoPinEdgeToSuperviewEdge(.Leading)
//            footerView.autoPinEdgeToSuperviewEdge(.Trailing)
//            footerView.autoPinEdgeToSuperviewEdge(.Bottom)
//            
//            footerLabel.autoAlignAxisToSuperviewAxis(.Horizontal)
//            footerLabel.autoPinEdge(.Left, toEdge: .Right, ofView: footerImageView, withOffset: 5)
//            
//            footerImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 5)
//            footerImageView.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
}