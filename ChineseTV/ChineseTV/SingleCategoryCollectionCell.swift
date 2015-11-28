//
//  SingleCategoryCollectionCell.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/11/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import ParseUI

class SingleCategoryCollectionCell: PFCollectionViewCell {
    
    var didSetupConstraints = false
    
    var mainContainer:UIView = UIView.newAutoLayoutView()
    var videoThumbnailView:UIImageView = UIImageView.newAutoLayoutView()
    var videoTitle:UILabel = UILabel.newAutoLayoutView()
    
    override func awakeFromNib() {
        
        contentView.backgroundColor = dividerColor
        
        mainContainer.backgroundColor = UIColor.whiteColor()
        mainContainer.layer.cornerRadius = 5
        
        let layer = mainContainer.layer
        layer.shadowColor = UIColor.lightGrayColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 5
        
        videoThumbnailView.contentMode = .ScaleAspectFill
        videoThumbnailView.clipsToBounds = true
        
        videoTitle.font = UIFont.systemFontOfSize(15)
        videoTitle.lineBreakMode = .ByTruncatingTail
        videoTitle.numberOfLines = 0
        videoTitle.textAlignment = .Left
        videoTitle.textColor = UIColor.blackColor()
        videoTitle.backgroundColor = UIColor.whiteColor()
        videoTitle.sizeToFit()
        
        contentView.addSubview(mainContainer)
        mainContainer.addSubview(videoThumbnailView)
        mainContainer.addSubview(videoTitle)
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
            mainContainer.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5))
            
            videoTitle.autoMatchDimension(.Height, toDimension: .Height, ofView: mainContainer, withMultiplier: 0.2, relation: NSLayoutRelation.GreaterThanOrEqual)
            videoTitle.autoPinEdgeToSuperviewEdge(.Leading)
            videoTitle.autoPinEdgeToSuperviewEdge(.Trailing)
            videoTitle.autoPinEdgeToSuperviewEdge(.Bottom)
            videoTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: videoThumbnailView, withOffset: -35)
            
            videoThumbnailView.autoPinEdgeToSuperviewEdge(.Leading)
            videoThumbnailView.autoPinEdgeToSuperviewEdge(.Trailing)
            videoThumbnailView.autoMatchDimension(.Height, toDimension: .Height, ofView: mainContainer, withMultiplier: 1.2, relation: NSLayoutRelation.LessThanOrEqual)
            
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
}
