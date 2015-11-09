//
//  LeftMenuHeaderCell.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/23/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import UIColor_Hex_Swift

class LeftMenuHeaderCell: UITableViewCell {
    
    let logoHeight:CGFloat = UIScreen.mainScreen().bounds.size.height*0.21
    
    var didSetupConstraints = false
    
    var mainContainer:UIView = UIView.newAutoLayoutView()
    var mainLogoView:UIImageView = UIImageView.newAutoLayoutView()
    var homeButton:UIButton = UIButton.newAutoLayoutView()
    
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
        
        let dogGif = UIImage.gifWithName("dog")
        mainLogoView.image = dogGif
        mainLogoView.autoSetDimensionsToSize(CGSize(width: logoHeight, height: logoHeight))
        mainLogoView.layer.borderWidth = 0.1
        mainLogoView.layer.masksToBounds = true
        mainLogoView.layer.borderColor = UIColor.whiteColor().CGColor
        mainLogoView.layer.cornerRadius = logoHeight/2
        mainLogoView.clipsToBounds = true
        mainLogoView.contentMode = .ScaleAspectFill
        
        let homeImage = UIImage(named: "ic_home")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        homeButton.setImage(homeImage, forState: .Normal)
        homeButton.tintColor = UIColor.whiteColor()
        
        contentView.addSubview(mainContainer)
        mainContainer.addSubview(mainLogoView)
        mainLogoView.addSubview(homeButton)
        
    }
    
    override func updateConstraints() {
        
        if !self.didSetupConstraints {
            
            mainContainer.autoPinEdgeToSuperviewEdge(.Left)
            mainContainer.autoPinEdgeToSuperviewEdge(.Top)
            mainContainer.autoPinEdgeToSuperviewEdge(.Bottom)
            mainContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: contentView, withMultiplier: 0.5)
            
            mainLogoView.autoCenterInSuperview()
            
            homeButton.autoSetDimension(.Height, toSize: 20)
            homeButton.autoAlignAxisToSuperviewAxis(.Vertical)
            homeButton.autoPinEdgeToSuperviewEdge(.Bottom)
    
            self.didSetupConstraints = true
        }
        
        super.updateConstraints()
    }

}
