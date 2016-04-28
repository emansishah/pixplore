//
//  SettingsViewController.swift
//  Pixplore
//
//  Created by Ali Shelton on 4/24/16.
//  Copyright © 2016 Mansi Shah. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var uploadImage: UIImageView!
    var tempImage = UIImage()
    var currentUser = PFUser.currentUser()
    @IBOutlet weak var changePic: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: "imageTapped:")
        changePic.addGestureRecognizer(tapGesture)
        changePic.userInteractionEnabled = true
        uploadImage.layer.borderWidth = 1
        uploadImage.layer.cornerRadius = uploadImage.frame.height/2
        uploadImage.clipsToBounds = true
        navBar.title = ""
        var label = UILabel(frame: CGRect(x: (self.view.bounds.width - 200)/2, y: 0, width: 200, height: 100))
        label.text = "SETTINGS"
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Raleway~SemiBold", size: 18)
        navBar.titleView = label
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if let label = gesture.view as? UILabel{
                choosePicture(gesture)
            }
        }
    
    @IBAction func backPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func choosePicture(sender: AnyObject) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        tempImage = image
        uploadImage.image = tempImage
        print(uploadImage.image)
        let imageFile = PFFile(name: "profile.png", data: UIImageJPEGRepresentation(uploadImage.image!, 0.5)!)
        currentUser!["profileImage"] = imageFile
        currentUser?.saveInBackgroundWithTarget(nil, selector: nil)
    }


    @IBAction func logoutButton(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("toInitial", sender: self)
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
