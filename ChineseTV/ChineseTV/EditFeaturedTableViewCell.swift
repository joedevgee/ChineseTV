//
//  EditFeaturedTableViewCell.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 1/10/16.
//  Copyright © 2016 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import ParseUI

class EditFeaturedTableViewCell: UITableViewCell {
    
    var didSetupConstraints = false
    var listImageView = PFImageView.newAutoLayoutView()
    var listNameLabel = UILabel.newAutoLayoutView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        contentView.backgroundColor = UIColor.clearColor()
        listImageView.contentMode = .ScaleAspectFill
        listImageView.clipsToBounds = true
        listNameLabel.font = UIFont.systemFontOfSize(12)
        listNameLabel.textAlignment = .Left
        listNameLabel.numberOfLines = 1
        contentView.addSubview(listImageView)
        contentView.addSubview(listNameLabel)
    }
    
    override func updateConstraintsIfNeeded() {
        if !self.didSetupConstraints {
            
            listImageView.autoSetDimension(.Height, toSize: UIScreen.mainScreen().bounds.width*0.4)
            listImageView.autoPinEdgeToSuperviewEdge(.Leading)
            listImageView.autoPinEdgeToSuperviewEdge(.Top)
            listImageView.autoPinEdgeToSuperviewEdge(.Trailing)
            
            listNameLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: listImageView)
            listNameLabel.autoPinEdgeToSuperviewEdge(.Leading)
            listNameLabel.autoPinEdgeToSuperviewEdge(.Trailing)
            listNameLabel.autoPinEdgeToSuperviewEdge(.Bottom)
            
            self.didSetupConstraints = true
        }
        super.updateConstraints()
    }

}
