//
//  LeftMenuTableViewCell.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/23/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import ParseUI
import PureLayout
import UIColor_Hex_Swift

class LeftMenuTableViewCell: PFTableViewCell {
        
    let rowHeight:CGFloat = UIScreen.mainScreen().bounds.size.height/6
    
    var didSetupConstraints = false
    
    var mainContainer:UIView = UIView.newAutoLayoutView()
    var categoryImageView:UIImageView = UIImageView.newAutoLayoutView()
    var categoryName:UILabel = UILabel.newAutoLayoutView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        contentView.backgroundColor = sideMenuColor
        
        mainContainer.backgroundColor = sideMenuColor
        mainContainer.layer.borderColor = sideMenuColor.CGColor
        
        categoryImageView.contentMode = .ScaleAspectFit
        let imageHeight:CGFloat = rowHeight*0.3
        categoryImageView.autoSetDimensionsToSize(CGSizeMake(imageHeight, imageHeight))
        categoryImageView.layer.borderWidth = 0.5
        categoryImageView.layer.masksToBounds = true
        categoryImageView.layer.borderColor = UIColor.clearColor().CGColor
        categoryImageView.layer.cornerRadius = imageHeight*0.5
        categoryImageView.clipsToBounds = true
        
        categoryName.text = " "
        categoryName.textColor = UIColor.whiteColor()
        categoryName.textAlignment = .Left
        categoryName.font = UIFont.boldSystemFontOfSize(12)
        categoryName.sizeToFit()
        
        contentView.addSubview(mainContainer)
        mainContainer.addSubview(categoryImageView)
        mainContainer.addSubview(categoryName)
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
            mainContainer.autoPinEdgeToSuperviewEdge(.Left)
            mainContainer.autoPinEdgeToSuperviewEdge(.Top)
            mainContainer.autoPinEdgeToSuperviewEdge(.Bottom)
            mainContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: contentView, withMultiplier: 0.5)
            
            categoryImageView.autoAlignAxisToSuperviewAxis(.Horizontal)
            categoryImageView.autoPinEdgeToSuperviewEdge(.Left, withInset: 5)
            
            categoryName.autoPinEdge(.Left, toEdge: .Right, ofView: categoryImageView, withOffset: 10)
            categoryName.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state

    }
    
}
