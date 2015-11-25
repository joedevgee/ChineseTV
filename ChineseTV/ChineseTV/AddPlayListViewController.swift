//
//  AddPlayListViewController.swift
//  ChineseTV
//
//  Created by Qiaowei Liu on 11/9/15.
//  Copyright © 2015 Qiaowei Liu. All rights reserved.
//

import UIKit
import PureLayout
import Parse
import SDWebImage
import Alamofire
import TTGSnackbar

class AddPlayListViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var listNameTextField:UITextField = UITextField.newAutoLayoutView()
    var descNameTextField:UITextField = UITextField.newAutoLayoutView()
    var subTitleTextField:UITextField = UITextField.newAutoLayoutView()
    var thumbnailImageView:UIImageView = UIImageView.newAutoLayoutView()
    var prevButton:UIButton = UIButton.newAutoLayoutView()
    var nextButton:UIButton = UIButton.newAutoLayoutView()
    var imageDoneButton:UIButton = UIButton.newAutoLayoutView()
    var categoryDoneButton:UIButton = UIButton.newAutoLayoutView()
    
    var displayNameLabel:UILabel = UILabel.newAutoLayoutView()
    var displaySubtitleLabel:UILabel = UILabel.newAutoLayoutView()
    var displayCategoryLabel:UILabel = UILabel.newAutoLayoutView()
    
    var categoryPicker:UIPickerView = UIPickerView.newAutoLayoutView()
    let saveCategory = ["drama","reality","talkshow"]
    
    var thumbnailsArray = [String]()
    var imagePosition:Int?
    
    var saveListID:String = ""
    var saveImageUrl:String = ""
    var saveListName:String = ""
    var saveListDescName:String = ""
    var saveListSubtitle:String = ""
    var saveListCategory:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupNavBar()
        self.setupInputViews()
        self.checkPasteBoard()
        // Touch anywhere to dismiss keyboard
        let tapDismiss:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapDismiss)
    }
    
    // Function to dismiss keyboard
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func checkPasteBoard() {
        if let youtubeLink = UIPasteboard.generalPasteboard().string {
            if youtubeLink.rangeOfString("http://www.youtube.com/playlist?list=") != nil {
                let playListID = youtubeLink.substringFromIndex(youtubeLink.startIndex.advancedBy(37))
                self.saveListID = playListID
                let resultNumber:Int = 50
                Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(resultNumber)&playlistId=\(playListID)&key=\(googleApiKey)")
                    .responseJSON { response in
                        if let JSON = response.result.value {
                            if let items = JSON["items"] as? Array<AnyObject> {
                                self.processResultItems(items)
                            }
                        }
                }
            }
        }
    }
    
    func processResultItems(items: Array<AnyObject>) {
        
        for video in items {
            if let videoDict:Dictionary<NSObject, AnyObject> = video as? Dictionary<NSObject, AnyObject> {
                if let snippetDict:Dictionary<NSObject, AnyObject> = videoDict["snippet"] as? Dictionary<NSObject, AnyObject> {
                    if let thumbnailsDict:Dictionary<NSObject, AnyObject> = snippetDict["thumbnails"] as? Dictionary<NSObject, AnyObject> {
                        if let imageUrl = thumbnailsDict["high"]?["url"] as? String {
                            self.thumbnailsArray.append(imageUrl)
                        }
                    }
                }
            }
        }
        if let firstImageUrl:String = thumbnailsArray[0] as String {
            self.thumbnailImageView.sd_setImageWithURL(NSURL(string: firstImageUrl))
            self.imagePosition = 0
        }
    }
    
    func loadPreviousImage() {
        if let loadingPosition:Int = (self.imagePosition! - 1) where self.imagePosition! >= 1 {
            let imageUrl:String = self.thumbnailsArray[loadingPosition] as String
            self.thumbnailImageView.sd_setImageWithURL(NSURL(string: imageUrl))
            self.saveImageUrl = imageUrl
            self.imagePosition! -= 1
        } else {
            print("This is the first image")
        }
    }
    
    func loadNextImage() {
        if let loadingPosition:Int = (self.imagePosition! + 1) where self.imagePosition! < (self.thumbnailsArray.count - 1) {
            let imageUrl:String = self.thumbnailsArray[loadingPosition] as String
            self.thumbnailImageView.sd_setImageWithURL(NSURL(string: imageUrl))
            self.saveImageUrl = imageUrl
            self.imagePosition! += 1
        } else {
            print("This is the last image")
        }
    }

    func setupNavBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("exitView"))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("savePlayList"))
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    func setupInputViews() {
        listNameTextField.delegate = self
        listNameTextField.layer.borderWidth = 0.5
        listNameTextField.layer.borderColor = themeColor.CGColor
        listNameTextField.font = UIFont.systemFontOfSize(18)
        listNameTextField.placeholder = "Enter the list name for display(short)"
        listNameTextField.sizeToFit()
        self.view.addSubview(listNameTextField)
        listNameTextField.autoPinToTopLayoutGuideOfViewController(self, withInset: 10)
        listNameTextField.autoPinEdgeToSuperviewEdge(.Leading, withInset: 10)
        listNameTextField.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 10)
        
        descNameTextField.delegate = self
        descNameTextField.layer.borderWidth = 0.5
        descNameTextField.layer.borderColor = themeColor.CGColor
        descNameTextField.font = UIFont.systemFontOfSize(18)
        descNameTextField.placeholder = "Enter a description of the list"
        descNameTextField.sizeToFit()
        self.view.addSubview(descNameTextField)
        descNameTextField.autoPinEdge(.Top, toEdge: .Bottom, ofView: listNameTextField, withOffset: 5)
        descNameTextField.autoPinEdgeToSuperviewEdge(.Leading, withInset: 10)
        descNameTextField.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 10)
        
        subTitleTextField.delegate = self
        subTitleTextField.layer.borderWidth = 0.5
        subTitleTextField.layer.borderColor = themeColor.CGColor
        subTitleTextField.font = UIFont.systemFontOfSize(18)
        subTitleTextField.placeholder = "This will appear on top of thumbnail"
        subTitleTextField.sizeToFit()
        self.view.addSubview(subTitleTextField)
        subTitleTextField.autoPinEdge(.Top, toEdge: .Bottom, ofView: descNameTextField, withOffset: 10)
        subTitleTextField.autoPinEdgeToSuperviewEdge(.Leading, withInset: 10)
        subTitleTextField.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 10)
        
        thumbnailImageView.backgroundColor = UIColor.lightGrayColor()
        thumbnailImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(thumbnailImageView)
        thumbnailImageView.autoSetDimensionsToSize(CGSize(width: 200, height: 180))
        thumbnailImageView.autoCenterInSuperview()
        
        prevButton.setTitle("Previous", forState: .Normal)
        prevButton.addTarget(self, action: "loadPreviousImage", forControlEvents: .TouchUpInside)
        prevButton.backgroundColor = UIColor.redColor()
        self.view.addSubview(prevButton)
        prevButton.autoSetDimensionsToSize(CGSize(width: 100, height: 100))
        prevButton.autoPinEdgeToSuperviewEdge(.Left, withInset: 10)
        prevButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: thumbnailImageView, withOffset: 20)
        
        nextButton.setTitle("Next", forState: .Normal)
        nextButton.backgroundColor = UIColor.redColor()
        nextButton.addTarget(self, action: "loadNextImage", forControlEvents: .TouchUpInside)
        self.view.addSubview(nextButton)
        nextButton.autoSetDimensionsToSize(CGSize(width: 100, height: 100))
        nextButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: thumbnailImageView, withOffset: 20)
        nextButton.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 5)
        
        imageDoneButton.setTitle("Save Image", forState: .Normal)
        imageDoneButton.backgroundColor = UIColor.greenColor()
        imageDoneButton.addTarget(self, action: "imageDone", forControlEvents: .TouchUpInside)
        self.view.addSubview(imageDoneButton)
        imageDoneButton.autoSetDimensionsToSize(CGSize(width: 100, height: 100))
        imageDoneButton.autoAlignAxisToSuperviewAxis(.Vertical)
        imageDoneButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: thumbnailImageView, withOffset: 10)
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        self.view.addSubview(categoryPicker)
        categoryPicker.hidden = true
        categoryPicker.autoCenterInSuperview()
        
        categoryDoneButton.setTitle("Save category", forState: .Normal)
        categoryDoneButton.backgroundColor = UIColor.greenColor()
        categoryDoneButton.addTarget(self, action: "categoryDone", forControlEvents: .TouchUpInside)
        self.view.addSubview(categoryDoneButton)
        categoryDoneButton.hidden = true
        categoryDoneButton.autoSetDimensionsToSize(CGSize(width: 100,height: 100))
        categoryDoneButton.autoAlignAxisToSuperviewAxis(.Vertical)
        categoryDoneButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: categoryPicker, withOffset: 10)
        
        displayNameLabel.textColor = UIColor.blackColor()
        displayNameLabel.textAlignment = .Center
        displayNameLabel.font = UIFont.systemFontOfSize(12)
        displayNameLabel.sizeToFit()
        self.view.addSubview(displayNameLabel)
        displayNameLabel.hidden = true
        displayNameLabel.autoPinToTopLayoutGuideOfViewController(self, withInset: 20)
        displayNameLabel.autoAlignAxisToSuperviewAxis(.Vertical)
        
        displaySubtitleLabel.textColor = UIColor.blackColor()
        displaySubtitleLabel.textAlignment = .Center
        displaySubtitleLabel.font = UIFont.systemFontOfSize(12)
        displaySubtitleLabel.sizeToFit()
        self.view.addSubview(displaySubtitleLabel)
        displaySubtitleLabel.hidden = true
        displaySubtitleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: displayNameLabel, withOffset: 10)
        displaySubtitleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
        
        displayCategoryLabel.textColor = UIColor.blackColor()
        displayCategoryLabel.textAlignment = .Center
        displayCategoryLabel.font = UIFont.systemFontOfSize(12)
        displayCategoryLabel.sizeToFit()
        self.view.addSubview(displayCategoryLabel)
        displayCategoryLabel.hidden = true
        displayCategoryLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: displaySubtitleLabel, withOffset: 10)
        displayCategoryLabel.autoAlignAxisToSuperviewAxis(.Vertical)
        
    }
    
    func imageDone() {
        if self.saveImageUrl.characters.count > 15 {
            thumbnailImageView.hidden = true
            prevButton.hidden = true
            nextButton.hidden = true
            imageDoneButton.hidden = true
            categoryPicker.hidden = false
            categoryDoneButton.hidden = false
        }
    }
    
    func categoryDone() {
        if self.saveListCategory.characters.count > 1 && self.listNameTextField.text?.characters.count > 1 && self.subTitleTextField.text?.characters.count > 1 {
            categoryPicker.hidden = true
            categoryDoneButton.hidden = true
            listNameTextField.hidden = true
            descNameTextField.hidden = true
            subTitleTextField.hidden = true
            self.saveListName = listNameTextField.text!
            self.saveListDescName = descNameTextField.text!
            self.saveListSubtitle = subTitleTextField.text!
            self.displaySubtitleLabel.hidden = false
            self.displayNameLabel.hidden = false
            self.displayCategoryLabel.hidden = false
            self.thumbnailImageView.hidden = false
            self.displayNameLabel.text = "\(saveListName): \(saveListDescName)"
            self.displaySubtitleLabel.text = saveListSubtitle
            self.displayCategoryLabel.text = saveListCategory
            navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    func savePlayList() {
        let savingPlayList = PFObject(className: "ChinesePlayList")
        savingPlayList["listName"] = self.saveListName
        savingPlayList["listDesc"] = self.saveListDescName
        savingPlayList["listSubtitle"] = self.saveListSubtitle
        savingPlayList["listID"] = self.saveListID
        savingPlayList["category"] = self.saveListCategory
        savingPlayList["thumbnailUrl"] = self.saveImageUrl
        savingPlayList.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                self.displayResult("New list has been saved to Parse")
            } else if error != nil {
                self.displayResult("Error occured during saving new list")
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func exitView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayResult(result: String!) {
        let resultBar = TTGSnackbar(message: result, duration: .Middle)
        resultBar.show()
    }
    
    //MARK: - Delegates and data sources for uipickerview
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return saveCategory.count
    }
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return saveCategory[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.saveListCategory = self.saveCategory[row]
        print(self.saveListCategory)
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = saveCategory[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
}
