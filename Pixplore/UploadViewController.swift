//
//  UploadViewController.swift
//  Pixplore
//
//  Created by Mansi Shah on 4/2/16.
//  Copyright © 2016 Mansi Shah. All rights reserved.
//

import UIKit
import Parse
import AssetsLibrary
import CoreLocation

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var hasMovedUp = false
    var isCurrentlyPosting = false
    
    @IBOutlet weak var navBar: UINavigationItem!
    //Image variable
    var tempImage = UIImage()
    
    //User variable
    var currentUser = PFUser.currentUser()
    
    //Location variables
    var userLocation = PFGeoPoint()
    var lat = CLLocationDegrees()
    var lon = CLLocationDegrees()
    var selectPicture = false
    
    //Outlet images
    @IBOutlet var uploadImage: UIImageView!
    @IBOutlet var captionTextView: UITextView!
    
    @IBOutlet var postButton: UIButton!
    
    @IBAction func backFromUpload(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //Keyboard resign
        captionTextView.delegate = self
        captionTextView.text = "Caption"
        captionTextView.textColor = UIColor.lightGrayColor()
        captionTextView.scrollEnabled = true
        navBar.title = ""
        var label = UILabel(frame: CGRect(x: (self.view.bounds.width - 200)/2, y: 0, width: 200, height: 100))
        label.text = "UPLOAD"
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Raleway~SemiBold", size: 18)
        navBar.titleView = label
    }
    
    func textViewShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
        if !hasMovedUp {
            hasMovedUp = true
            UIView.animateWithDuration(0.3, delay: 0.1, options: [.CurveEaseOut], animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, -UIScreen.mainScreen().bounds.height/3 + 10)
                }, completion: nil)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "Caption"
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        if hasMovedUp {
            UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseIn], animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, UIScreen.mainScreen().bounds.height/3 - 10)
                }, completion: nil)
        }
        hasMovedUp = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        getUserLocation()

        if (selectPicture){
            UIView.animateWithDuration(0.1, delay: 0.1, options: [.CurveLinear], animations: {
                self.postButton.backgroundColor = UIColor(red: 90.0/255.0, green: 199.0/255.0, blue: 103.0/255.0, alpha: 1)
                }, completion: nil)
            
        }
        //To make the border look very close to a UITextField
        captionTextView.layer.borderColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 0.5).CGColor
        captionTextView.layer.borderWidth = 1
        
        //The rounded corner part, where you specify your view's corner radius:
        captionTextView.layer.cornerRadius = 5
        captionTextView.clipsToBounds = true
        
        

    }

    /**
     Resigning the keyboard
     */

    
    /**
     Alerts functions
     */
    func displayAlert(title: String, displayError: String) {
        let alert = UIAlertController(title: title, message: displayError, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {action in print("bad stuff happened")}))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func getUserLocation() {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.userLocation = geoPoint!
                print(self.userLocation)
            }
        }
    }
    
    
    /**
     Posting the picture
     */
    @IBAction func postPicture(sender: AnyObject) {
        var displayError = ""
        if uploadImage.image == nil {
            displayError = "Please choose a photo."
        }
        if displayError != "" {
            displayAlert("Error in Form", displayError: displayError)
        
        } else {
            if !isCurrentlyPosting {
                isCurrentlyPosting = true
            //Picture object
            
            let picture = PFObject(className: "Photo")
            
            //Adding all fields's
            if captionTextView.text == "Caption" {
                picture["description"] = ""
            } else {
                picture["description"] = captionTextView.text
            }
            picture["numberofSaves"] = 0
            picture["location"] = PFGeoPoint(latitude: self.lat, longitude: self.lon)
            picture["username"] = self.currentUser?.username
            //picture["uploadUser"] = self.currentUser
            picture["uploadingUser"] = PFUser.currentUser()
            
            //Gathering and uploading picture
            
            let croppedImage = cropToSquare(image: uploadImage.image!)
            let pictureUsed = PFFile(name: "photoUsed.png", data: UIImageJPEGRepresentation(croppedImage, 0.5)!)
            
            
            picture["photo"] = pictureUsed
            
            //Saving the picture
            picture.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
//                    let vc = self.presentingViewController as! UITabBarController
//                    if (vc is FeedViewController) {
//                        print("feedView")
//                    }
//                    let actualVc = vc.selectedViewController as! FeedViewController
////                    let actualVc = navVc.rootViewController
//                    actualVc.segmentView.selectedSegmentIndex = 1
//                    actualVc.refresh()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            }
        }
    }
    
    /**
     Picking image and stripping location data
     */
    
    @IBAction func choosePicture(sender: AnyObject) {
        let alertCont = UIAlertController(title: "Pick Source", message: "", preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Take Photo", style: .Default) { (action) in
            //Display Camera
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.Camera
            image.allowsEditing = false
            self.presentViewController(image, animated: true, completion: nil)
            self.selectPicture = true
        }
        let libraryAction = UIAlertAction(title: "Pick from Library", style: .Default) { (action) in
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            image.allowsEditing = false
            self.presentViewController(image, animated: true, completion: nil)
            self.selectPicture = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertCont.addAction(cameraAction)
        alertCont.addAction(libraryAction)
        alertCont.addAction(cancelAction)
        self.presentViewController(alertCont, animated: true, completion: nil)
       
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: { () in
            if (picker.sourceType == .PhotoLibrary) {
                self.tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                self.uploadImage.image = self.cropToSquare(image: self.tempImage)
                let library = ALAssetsLibrary()
                let url: NSURL = info[UIImagePickerControllerReferenceURL] as! NSURL
                
                library.assetForURL(url, resultBlock: { (asset: ALAsset!) in
                    if asset.valueForProperty(ALAssetPropertyLocation) != nil {
                        let latitude = (asset.valueForProperty(ALAssetPropertyLocation) as! CLLocation!).coordinate.latitude
                        let longitude = (asset.valueForProperty(ALAssetPropertyLocation) as! CLLocation!).coordinate.longitude
                        self.lat = latitude
                        self.lon = longitude
                        print("\(latitude), \(longitude)")
                    }
                    },
                    failureBlock: { (error: NSError!) in
                        print(error.localizedDescription)
                })
            }
            if (picker.sourceType == .Camera) {
                self.tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                self.uploadImage.image = self.cropToSquare(image: self.tempImage)
                PFGeoPoint.geoPointForCurrentLocationInBackground {
                    (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                    if error == nil {
                        let userLoc = geoPoint!
                        self.lat = userLoc.latitude
                        self.lon = userLoc.longitude
                        print(self.lat, self.lon)
                    }
                }
            }
        })
    }
    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}
