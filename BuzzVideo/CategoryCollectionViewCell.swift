//
//  CategoryCollectionViewCell.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/24/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import ParseUI

class CategoryCollectionViewCell: PFCollectionViewCell {
    
    var didSetupConstraints = false
    
    var videoThumbnailView:UIImageView = UIImageView.newAutoLayoutView()
    var videoTitle:UILabel = UILabel.newAutoLayoutView()
    
    override func awakeFromNib() {
        
        contentView.backgroundColor = UIColor.whiteColor()
        
        videoThumbnailView.contentMode = .ScaleAspectFill
        videoThumbnailView.clipsToBounds = true
        
        videoTitle.font = UIFont.flatFontOfSize(12)
        videoTitle.lineBreakMode = .ByTruncatingTail
        videoTitle.numberOfLines = 0
        videoTitle.textAlignment = .Left
        videoTitle.textColor = UIColor.blackColor()
        videoTitle.sizeToFit()
        
        contentView.addSubview(videoThumbnailView)
        contentView.addSubview(videoTitle)
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
            videoThumbnailView.autoPinEdgeToSuperviewEdge(.Top)
            videoThumbnailView.autoPinEdgeToSuperviewEdge(.Leading)
            videoThumbnailView.autoPinEdgeToSuperviewEdge(.Trailing)
            videoThumbnailView.autoMatchDimension(.Height, toDimension: .Height, ofView: contentView, withMultiplier: 0.7)
            
            videoTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: videoThumbnailView)
            videoTitle.autoPinEdgeToSuperviewEdge(.Left)
            videoTitle.autoPinEdgeToSuperviewEdge(.Right)
            videoTitle.autoPinEdgeToSuperviewEdge(.Bottom)
            
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
    
}
