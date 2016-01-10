//
//  SignUpViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 12/27/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import Parse
import VBFPopFlatButton
import FontAwesomeKit
import Toucan

let registerNotificationKey:String = "com.8pon.userSuccessfullyRegistered"

let signUpViewSize:CGSize = CGSize(width: UIScreen.mainScreen().bounds.width*0.7, height: UIScreen.mainScreen().bounds.height*0.6)

protocol SignUpViewControllerDelegate {
    func didPassSignUp(controller: SignUpViewController, userID: String)
}

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var delegate: SignUpViewControllerDelegate?

    var mainContainer:UIView = UIView.newAutoLayoutView()
    var closeButton:UIButton = UIButton.newAutoLayoutView()
    var avatarImageView:UIImageView = UIImageView.newAutoLayoutView()
    var avatarLabel:UILabel = UILabel.newAutoLayoutView()
    var imageCheckButton:VBFPopFlatButton = VBFPopFlatButton.newAutoLayoutView()
    let imagePicker = UIImagePickerController()
    var nameField:MyTextField = MyTextField.newAutoLayoutView()
    
    var didSetupConstraints = false
    var didPickAvatar = false
    var didEnterName = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        nameField.delegate = self
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.clearColor()
        mainContainer.backgroundColor = UIColor.clearColor()
        view.addSubview(mainContainer)
        
        closeButton.addTarget(self, action: "closeView", forControlEvents: .TouchUpInside)
        let closeIcon:FAKFontAwesome = FAKFontAwesome.closeIconWithSize(30)
        closeIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        closeIcon.drawingBackgroundColor = UIColor.clearColor()
        let closeImage:UIImage = closeIcon.imageWithSize(CGSize(width: 30, height: 30))
        closeButton.setImage(closeImage, forState: .Normal)
        mainContainer.addSubview(closeButton)
        
        let avatarSize:CGSize = CGSizeMake(UIScreen.mainScreen().bounds.height/5, UIScreen.mainScreen().bounds.height/5)
        avatarImageView.autoSetDimensionsToSize(avatarSize)
        avatarImageView.layer.cornerRadius = avatarSize.width/2
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .ScaleAspectFill
        let githubIcon:FAKFontAwesome = FAKFontAwesome.githubIconWithSize(160)
        githubIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        githubIcon.drawingBackgroundColor = themeColor
        let githubImage:UIImage = githubIcon.imageWithSize(avatarSize)
        avatarImageView.image = githubImage
        let showTap = UITapGestureRecognizer(target: self, action: "showPhotos")
        avatarImageView.userInteractionEnabled = true
        avatarImageView.addGestureRecognizer(showTap)
        avatarLabel.text = "上传头像"
        avatarLabel.textColor = UIColor.whiteColor()
        avatarLabel.textAlignment = .Center
        avatarLabel.font = UIFont.systemFontOfSize(18)
        avatarImageView.addSubview(avatarLabel)
        mainContainer.addSubview(avatarImageView)
        
        imageCheckButton = VBFPopFlatButton(frame: CGRectMake(0, 0, 30, 30), buttonType: FlatButtonType.buttonAddType, buttonStyle: FlatButtonStyle.buttonRoundedStyle, animateToInitialState: true)
        imageCheckButton.roundBackgroundColor = themeColor
        imageCheckButton.lineThickness = 2
        imageCheckButton.tintColor = UIColor.whiteColor()
        imageCheckButton.addTarget(self, action: Selector("buttonActions:"), forControlEvents: .TouchUpInside)
        mainContainer.addSubview(imageCheckButton)
        
        nameField.layer.borderWidth = 2
        nameField.layer.borderColor = UIColor(red: 54/255, green: 215/255, blue: 183/255, alpha: 1).CGColor
        nameField.placeholder = "请输入您的昵称......."
        nameField.backgroundColor = UIColor.whiteColor()
        nameField.font = UIFont.boldSystemFontOfSize(20)
        nameField.hidden = true
        mainContainer.addSubview(nameField)
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            
            mainContainer.autoSetDimensionsToSize(signUpViewSize)
            mainContainer.autoPinEdgeToSuperviewEdge(.Top)
            mainContainer.autoPinEdgeToSuperviewEdge(.Leading)
            
            closeButton.autoPinEdgeToSuperviewEdge(.Top)
            closeButton.autoPinEdgeToSuperviewEdge(.Leading)
            
            avatarImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 35)
            avatarImageView.autoAlignAxisToSuperviewAxis(.Vertical)
            
            avatarLabel.autoCenterInSuperview()
            
            imageCheckButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: avatarImageView, withOffset: 35)
            imageCheckButton.autoAlignAxis(.Vertical, toSameAxisOfView: avatarImageView)
            
            nameField.autoAlignAxisToSuperviewAxis(.Vertical)
            nameField.autoAlignAxis(.Horizontal, toSameAxisOfView: avatarImageView)
            nameField.autoPinEdgeToSuperviewEdge(.Leading, withInset: 10)
            nameField.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 10)
            
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
    
    // MARK: Image picker delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if let pickedImage:UIImage = image as UIImage {
            avatarImageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
        avatarLabel.hidden = true
        imageCheckButton.roundBackgroundColor = UIColor(red: 54/255, green: 215/255, blue: 183/255, alpha: 1)
        imageCheckButton.animateToType(FlatButtonType.buttonForwardType)
    }
    
    //MARK: textfield delegate
    // Check if user has entered something in the text field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string.characters.count == 0 {
            // Text field is empty
            imageCheckButton.roundBackgroundColor = themeColor
            imageCheckButton.animateToType(FlatButtonType.buttonUpBasicType)
        } else {
            imageCheckButton.roundBackgroundColor = UIColor(red: 54/255, green: 215/255, blue: 183/255, alpha: 1)
            imageCheckButton.animateToType(FlatButtonType.buttonOkType)
        }
        return true
    }
    
    func showPhotos() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func buttonActions(sender: VBFPopFlatButton) {
        switch sender.currentButtonType {
        case FlatButtonType.buttonAddType:
            self.showPhotos()
        case FlatButtonType.buttonForwardType:
            avatarImageView.hidden = true
            nameField.hidden = false
            nameField.becomeFirstResponder()
            sender.roundBackgroundColor = themeColor
            sender.animateToType(.buttonUpBasicType)
        case FlatButtonType.buttonOkType:
            nameField.hidden = true
            imageCheckButton.hidden = true
            UIView.animateWithDuration(1.2, delay: 0.0, options: .BeginFromCurrentState, animations: {
                let finalImageView:UIImageView = UIImageView.newAutoLayoutView()
                let finalSize:CGSize = CGSize(width: 90, height: 90)
                finalImageView.autoSetDimensionsToSize(finalSize)
                finalImageView.layer.cornerRadius = finalSize.width/2
                finalImageView.layer.borderWidth = 0
                finalImageView.clipsToBounds = true
                finalImageView.contentMode = .ScaleAspectFill
                finalImageView.image = self.avatarImageView.image
                self.mainContainer.addSubview(finalImageView)
                finalImageView.autoAlignAxis(.Horizontal, toSameAxisOfView: self.mainContainer, withOffset: -55)
                finalImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 10)
                let nameLabel:UILabel = UILabel.newAutoLayoutView()
                nameLabel.text = self.nameField.text
                nameLabel.textColor = UIColor.whiteColor()
                nameLabel.textAlignment = .Left
                nameLabel.font = UIFont.boldSystemFontOfSize(23)
                nameLabel.numberOfLines = 2
                self.mainContainer.addSubview(nameLabel)
                nameLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: finalImageView, withOffset: -20)
                nameLabel.autoPinEdge(.Leading, toEdge: .Trailing, ofView: finalImageView, withOffset: 20, relation: .LessThanOrEqual)
                nameLabel.autoPinEdgeToSuperviewEdge(.Trailing)
                let finalButton:UIButton = UIButton.newAutoLayoutView()
                finalButton.setTitle("确认注册", forState: .Normal)
                finalButton.backgroundColor = UIColor(red: 54/255, green: 215/255, blue: 183/255, alpha: 1)
                finalButton.layer.cornerRadius = 5
                finalButton.layer.borderColor = UIColor.whiteColor().CGColor
                finalButton.layer.borderWidth = 2
                finalButton.tintColor = UIColor.whiteColor()
                finalButton.titleLabel?.font = UIFont.systemFontOfSize(20)
                finalButton.addTarget(self, action: "saveUser", forControlEvents: .TouchUpInside)
                self.mainContainer.addSubview(finalButton)
                finalButton.autoAlignAxisToSuperviewAxis(.Vertical)
                finalButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: finalImageView, withOffset: 20)
                finalButton.autoMatchDimension(.Width, toDimension: .Width, ofView: self.mainContainer, withMultiplier: 0.5)
                self.mainContainer.layoutIfNeeded()
                }, completion: nil)
            
        default:
            print("Nothing to do")
        }
    }
    
    func saveUser() {
        // Save the user info to Parse
        guard let image = self.avatarImageView.image else { print("No image in image view");return }
        let resizedImage = Toucan(image: image).resizeByCropping(CGSize(width: 30, height: 30)).image
        guard let imageData = UIImageJPEGRepresentation(resizedImage, 0.38) else { print("Compressing image failed");return }
        guard let imageFile = PFFile(name: "avatar.jpeg", data: imageData) else { print("Converting to pffile failed");return }
        guard let userName: String = self.nameField.text else { print("Getting username failed");return }
        let userProfile = PFObject(className: "UserProfile")
        userProfile["avatar"] = imageFile
        userProfile["name"] = userName
        userProfile.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            // Handle success or failure here ...
            if succeeded {
                guard let userID = userProfile.objectId else { return }
                guard let imageUrl = imageFile.url else { return }
                NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "userName")
                NSUserDefaults.standardUserDefaults().setObject(imageUrl, forKey: "userAvatarUrl")
                NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "userID")
                if let delegate = self.delegate { delegate.didPassSignUp(self, userID: userID) }
            }
        })
        // Close the pop up view
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

class MyTextField:UITextField {
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 5, 5)
    }
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 5, 5)
    }
}
