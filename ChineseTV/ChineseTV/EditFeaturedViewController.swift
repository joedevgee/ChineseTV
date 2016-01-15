//
//  EditFeaturedViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 1/10/16.
//  Copyright © 2016 Qiaowei Liu. All rights reserved.
//

import UIKit
import ParseUI
import PureLayout
import Parse
import Toucan

class EditFeaturedViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var objectId:String?
    var featuredImage = PFImageView.newAutoLayoutView()
    var featuredName = UITextField.newAutoLayoutView()
    let imagePicker = UIImagePickerController()
    
    var didSetupConstraints = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveFeaturedList")
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
    }
    
    func updateListInfo(name: String, image: PFFile, parseId: String) {
        self.featuredImage.file = image
        self.featuredImage.loadInBackground()
        self.featuredName.text = name
        self.objectId = parseId
    }
    
    func pickImage() {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func saveFeaturedList() {
        if self.objectId != nil {
            let query = PFQuery(className: "FeaturedList")
            query.getObjectInBackgroundWithId(self.objectId!) {
                (list: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let list = list {
                    guard let savingImage = self.featuredImage.image else { return }
                    guard let imageData = UIImageJPEGRepresentation(savingImage, 0.6) else { return }
                    guard let imageFile = PFFile(name: "waterfall.jpeg", data: imageData) else { return }
                    guard let savingName:String = self.featuredName.text else { return }
                    list["Image"] = imageFile
                    list["listName"] = savingName
                    list.saveInBackground()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        let tap = UITapGestureRecognizer(target: self, action: "pickImage")
        featuredImage.userInteractionEnabled = true
        featuredImage.addGestureRecognizer(tap)
        featuredImage.contentMode = .ScaleAspectFill
        featuredImage.clipsToBounds = true
        featuredImage.backgroundColor = UIColor.lightGrayColor()
        featuredName.backgroundColor = UIColor.lightGrayColor()
        featuredName.font = UIFont.boldSystemFontOfSize(20)
        featuredName.textColor = UIColor.blackColor()
        view = UIView()
        view.addSubview(featuredImage)
        view.addSubview(featuredName)
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            featuredImage.autoSetDimensionsToSize(CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width*0.4))
            featuredImage.autoPinEdgeToSuperviewEdge(.Top, withInset: 20)
            featuredImage.autoPinEdgeToSuperviewEdge(.Leading)
            featuredImage.autoAlignAxisToSuperviewAxis(.Vertical)
            featuredName.autoMatchDimension(.Width, toDimension: .Width, ofView: featuredImage)
            featuredName.autoSetDimension(.Height, toSize: 35)
            featuredName.autoAlignAxis(.Vertical, toSameAxisOfView: featuredImage)
            featuredName.autoPinEdge(.Top, toEdge: .Bottom, ofView: featuredImage, withOffset: 20)
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }

    //MARK: uiimagepicker delegate method
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let resizedImage = Toucan(image: image).resizeByCropping(CGSize(width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width*0.4)).image
        self.featuredImage.image = resizedImage
        dismissViewControllerAnimated(true, completion: nil)
    }
}
