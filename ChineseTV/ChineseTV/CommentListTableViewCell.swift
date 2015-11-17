//
//  CommentListTableViewCell.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/12/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout

class VideoDetailCommentCell: UITableViewCell {
    
    var didSetupConstraints = false
    var topContainer:UIView = UIView.newAutoLayoutView()
    var avatarView:UIImageView = UIImageView.newAutoLayoutView()
    var commentLabel:UILabel = UILabel.newAutoLayoutView()
    var userNameLabel:UILabel = UILabel.newAutoLayoutView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        
        contentView.backgroundColor = videoSubColor
        
        avatarView.autoSetDimensionsToSize(CGSize(width: 25, height: 25))
        avatarView.layer.borderWidth = 0.1
        avatarView.layer.masksToBounds = true
        avatarView.layer.borderColor = UIColor.whiteColor().CGColor
        avatarView.layer.cornerRadius = 12.5
        avatarView.clipsToBounds = true
        
        userNameLabel.text = "user"
        userNameLabel.lineBreakMode = .ByTruncatingTail
        userNameLabel.textColor = UIColor.whiteColor()
        userNameLabel.font = UIFont.boldSystemFontOfSize(13)
        userNameLabel.textAlignment = .Left
        userNameLabel.numberOfLines = 1
        
        commentLabel.text = "Hi, I am a test comment label, am i getting to the second line"
        commentLabel.textColor = UIColor.whiteColor()
        commentLabel.font = UIFont.systemFontOfSize(12)
        commentLabel.textAlignment = .Left
        commentLabel.numberOfLines = 0
        contentView.addSubview(avatarView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(commentLabel)
    }
    
    override func updateConstraints() {
        if !self.didSetupConstraints {
            
            contentView.bounds = CGRect(x: 0.0, y: 0.0, width: 99999.0, height: 99999.0)
            
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired) {
                self.userNameLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.commentLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            }
            
            avatarView.autoPinEdgeToSuperviewEdge(.Top, withInset: 5)
            avatarView.autoPinEdgeToSuperviewEdge(.Left, withInset: 5)
            
            userNameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 5)
            userNameLabel.autoPinEdge(.Left, toEdge: .Right, ofView: avatarView, withOffset: 10)
            
            commentLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: userNameLabel, withOffset: 5, relation: .GreaterThanOrEqual)
            commentLabel.autoPinEdge(.Left, toEdge: .Right, ofView: avatarView, withOffset: 10)
            commentLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 10)
            commentLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 10, relation: .GreaterThanOrEqual)
            
            self.didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
}

class Comment {
    
    var name: String
    var avatarUrl: String
    var commentText: String
    
    init(name: String, avatarUrl: String, commentText: String) {
        self.name = name
        self.avatarUrl = avatarUrl
        self.commentText = commentText
    }
    
}
