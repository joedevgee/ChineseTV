//
//  LogInViewController.swift
//  BuzzVideo
//
//  Created by Qiaowei Liu on 10/28/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import Parse
import ParseUI

class LogInViewController: PFLogInViewController, PFLogInViewControllerDelegate {
    
    var titleLabel:UILabel = UILabel.newAutoLayoutView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logInView?.logo?.removeFromSuperview()
        self.view.addSubview(titleLabel)
        titleLabel.text = "To contribute videos, please login through Facebook or Twitter first. Don't worry, we do not post anything on your behalf"
        titleLabel.autoCenterInSuperview()
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 20)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 20)
        titleLabel.textAlignment = .Left
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFontOfSize(25)
        titleLabel.sizeToFit()
        
    }
    
}
