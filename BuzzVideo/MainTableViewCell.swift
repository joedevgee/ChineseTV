import UIKit
import PureLayout
import ParseUI
import UIColor_Hex_Swift

class MainTableViewCell: PFTableViewCell {
    
    var didSetupConstraints = false
    var mainContainer:UIView = UIView.newAutoLayoutView()
    var topView:UIView = UIView.newAutoLayoutView()
    var middleView:UIView = UIView.newAutoLayoutView()
    var bottomView:UIView = UIView.newAutoLayoutView()
    var footerView:UIView = UIView.newAutoLayoutView()
    var categoryImage:PFImageView = PFImageView.newAutoLayoutView()
    var categoryName:UILabel = UILabel.newAutoLayoutView()
    var viewImage:UIImageView = UIImageView.newAutoLayoutView()
    var viewCounts:UILabel = UILabel.newAutoLayoutView()
    var thumbnailImage:PFImageView = PFImageView.newAutoLayoutView()
    var videoTitle:UILabel = UILabel.newAutoLayoutView()
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
        
        let categoryImageSize:CGFloat = contentView.frame.height*0.5
        categoryImage.autoSetDimensionsToSize(CGSize(width: categoryImageSize, height: categoryImageSize))
        categoryImage.backgroundColor = UIColor.whiteColor()
        categoryImage.layer.borderWidth = 0.1
        categoryImage.layer.masksToBounds = true
        categoryImage.layer.borderColor = UIColor.whiteColor().CGColor
        categoryImage.layer.cornerRadius = categoryImageSize/2
        categoryImage.clipsToBounds = true
        
        categoryName.font = UIFont.boldSystemFontOfSize(10)
        categoryName.sizeToFit()
        
        thumbnailImage.contentMode = .ScaleAspectFill
        thumbnailImage.clipsToBounds = true
        
        videoTitle.lineBreakMode = .ByTruncatingTail
        videoTitle.numberOfLines = 2
        videoTitle.textAlignment = .Left
        videoTitle.textColor = UIColor.blackColor()
        videoTitle.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        videoTitle.sizeToFit()
        
        let footerImage = UIImage(named: "ic_visibility")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        footerImageView.tintColor = UIColor.lightGrayColor()
        footerImageView.image = footerImage
        footerImageView.contentMode = .ScaleAspectFit
        
        footerLabel.text = "23"
        footerLabel.font = UIFont.systemFontOfSize(8)
        footerLabel.textColor = UIColor.lightGrayColor()
        footerLabel.sizeToFit()
        
        mainContainer.backgroundColor = UIColor.whiteColor()
        mainContainer.layer.cornerRadius = 2.5
        contentView.backgroundColor = themeBackgroundColor
        
        contentView.addSubview(mainContainer)
        mainContainer.addSubview(topView)
        topView.addSubview(categoryImage)
        topView.addSubview(categoryName)
        mainContainer.addSubview(middleView)
        middleView.addSubview(thumbnailImage)
        mainContainer.addSubview(bottomView)
        bottomView.addSubview(videoTitle)
        mainContainer.addSubview(footerView)
        footerView.addSubview(footerLabel)
        footerView.addSubview(footerImageView)
        footerView.addSubview(footerLabel)
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
            mainContainer.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 5, left: 6, bottom: 5, right: 6))
            
            topView.autoMatchDimension(.Height, toDimension: .Height, ofView: mainContainer, withMultiplier: 0.15)
            topView.autoPinEdgeToSuperviewEdge(.Top)
            topView.autoPinEdgeToSuperviewEdge(.Leading)
            topView.autoPinEdgeToSuperviewEdge(.Trailing)
            
            categoryImage.autoAlignAxis(.Horizontal, toSameAxisOfView: topView)
            categoryImage.autoPinEdgeToSuperviewEdge(.Leading, withInset: 5)
            
            categoryName.autoAlignAxis(.Horizontal, toSameAxisOfView: categoryImage)
            categoryName.autoPinEdge(.Left, toEdge: .Right, ofView: categoryImage, withOffset: 5)
            
            middleView.autoMatchDimension(.Height, toDimension: .Height, ofView: mainContainer, withMultiplier: 0.5)
            middleView.autoPinEdgeToSuperviewEdge(.Leading)
            middleView.autoPinEdgeToSuperviewEdge(.Trailing)
            middleView.autoPinEdge(.Top, toEdge: .Bottom, ofView: topView)
            
            thumbnailImage.autoPinEdgesToSuperviewEdges()
            
            bottomView.autoMatchDimension(.Height, toDimension: .Height, ofView: mainContainer, withMultiplier: 0.25)
            bottomView.autoPinEdge(.Top, toEdge: .Bottom, ofView: middleView)
            bottomView.autoPinEdgeToSuperviewEdge(.Leading)
            bottomView.autoPinEdgeToSuperviewEdge(.Trailing)
            
            videoTitle.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
            
            footerView.autoPinEdge(.Top, toEdge: .Bottom, ofView: bottomView)
            footerView.autoPinEdgeToSuperviewEdge(.Leading)
            footerView.autoPinEdgeToSuperviewEdge(.Trailing)
            footerView.autoPinEdgeToSuperviewEdge(.Bottom)
            
            footerLabel.autoAlignAxisToSuperviewAxis(.Horizontal)
            footerLabel.autoPinEdge(.Left, toEdge: .Right, ofView: footerImageView, withOffset: 5)
            
            footerImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 5)
            footerImageView.autoAlignAxisToSuperviewAxis(.Horizontal)
            footerImageView.autoMatchDimension(.Width, toDimension: .Width, ofView: categoryImage, withMultiplier: 0.5)
            footerImageView.autoMatchDimension(.Height, toDimension: .Height, ofView: categoryImage, withMultiplier: 0.5)
            
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
}