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
    var videoTitle:subtitleTextLabel = subtitleTextLabel.newAutoLayoutView()
    var saveList:UIImageView = UIImageView.newAutoLayoutView()
    
    override func awakeFromNib() {
        
        contentView.backgroundColor = collectionBackColor
        
        mainContainer.backgroundColor = UIColor.whiteColor()
        mainContainer.layer.cornerRadius = 5
        
        videoThumbnailView.contentMode = .ScaleAspectFill
        videoThumbnailView.clipsToBounds = true
        
        videoTitle.font = UIFont.systemFontOfSize(10)
        videoTitle.lineBreakMode = .ByTruncatingTail
        videoTitle.numberOfLines = 2
        videoTitle.textAlignment = .Left
        videoTitle.textColor = UIColor.darkGrayColor()
        videoTitle.backgroundColor = UIColor.whiteColor()
        
        let favoriteImage = UIImage(named: "ic_favorite")?.imageWithRenderingMode(.AlwaysTemplate)
        saveList.tintColor = collectionBackColor
        saveList.image = favoriteImage
        saveList.backgroundColor = UIColor.clearColor()
        
        contentView.addSubview(mainContainer)
        mainContainer.addSubview(videoThumbnailView)
        mainContainer.addSubview(videoTitle)
        mainContainer.addSubview(saveList)
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
            mainContainer.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            
            saveList.autoPinEdgeToSuperviewEdge(.Right, withInset: 5, relation: .GreaterThanOrEqual)
            saveList.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5, relation: .GreaterThanOrEqual)
            
            videoTitle.autoMatchDimension(.Height, toDimension: .Height, ofView: mainContainer, withMultiplier: 0.2, relation: NSLayoutRelation.GreaterThanOrEqual)
            videoTitle.autoPinEdgeToSuperviewEdge(.Leading)
            videoTitle.autoPinEdgeToSuperviewEdge(.Trailing)
            videoTitle.autoPinEdge(.Bottom, toEdge: .Top, ofView: saveList)
            videoTitle.autoPinEdge(.Top, toEdge: .Bottom, ofView: videoThumbnailView, withOffset: -35)
            
            videoThumbnailView.autoPinEdgeToSuperviewEdge(.Leading)
            videoThumbnailView.autoPinEdgeToSuperviewEdge(.Trailing)
            videoThumbnailView.autoMatchDimension(.Height, toDimension: .Height, ofView: mainContainer, withMultiplier: 1.2, relation: NSLayoutRelation.LessThanOrEqual)
            
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
}

class subtitleTextLabel: UILabel {
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
}