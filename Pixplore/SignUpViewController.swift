//
//  SignUpViewController.swift
//  Pixplore
//
//  Created by Mansi Shah on 4/2/16.
//  Copyright © 2016 Mansi Shah. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    
//    var keyboardSize: CGFloat = 0.0
    var hasMovedUp = false
    var isCurrentlySigningUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.firstName.delegate = self
        self.confirmPassword.delegate = self
        self.email.delegate = self
        self.username.delegate = self
        self.password.delegate = self
        self.lastName.delegate = self
        self.signUpButton.highlighted = true
        self.loginButton.highlighted = false
//        loginButton.layer.cornerRadius = loginButton.frame.height/4.5
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func keyboardShown(notification: NSNotification) {
//        let info  = notification.userInfo!
//        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
//        
//        let rawFrame = value.CGRectValue
//        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
//        self.keyboardSize = rawFrame.height
//        
//    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        if hasMovedUp {
//            if !isCurrentlySigningUp {
//                UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseIn], animations: {
//                    self.view.frame = CGRectOffset(self.view.frame, 0, UIScreen.mainScreen().bounds.height/3 - 10)
//                    }, completion: nil)
//                hasMovedUp = false
//
//            }
        
//        }
//        if !isCurrentlySigningUp {
//            
//        }
        
        var nextTag = textField.tag + 1
        var nextRes = textField.superview?.viewWithTag(nextTag)
        if nextRes != nil {
            nextRes?.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //User starts typing
        if !hasMovedUp {
            hasMovedUp = true
            if !isCurrentlySigningUp {
                isCurrentlySigningUp = true
            }
            UIView.animateWithDuration(0.3, delay: 0.1, options: [.CurveEaseOut], animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, -UIScreen.mainScreen().bounds.height/3 + 10)
                }, completion: nil)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
//        if hasMovedUp {
//            UIView.animateWithDuration(0.3, delay: 0.1, options: [.CurveEaseIn], animations: {
//                self.view.frame = CGRectOffset(self.view.frame, 0, UIScreen.mainScreen().bounds.height/3 - 10)
//                }, completion: nil)
//        }
        if hasMovedUp {
            if !isCurrentlySigningUp {
                UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseIn], animations: {
                    self.view.frame = CGRectOffset(self.view.frame, 0, UIScreen.mainScreen().bounds.height/3 - 10)
                    }, completion: nil)
            }
            
        }
        if !isCurrentlySigningUp {
            hasMovedUp = false

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
    
    @IBAction func signInPressed(sender: AnyObject) {

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayAlert(title: String, displayError: String) {
        let alert = UIAlertController(title: title, message: displayError, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {action in
            
            
            //self.dismissViewControllerAnimated(true, completion: nil)
        
        
        
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func confirmSignUp(sender: AnyObject) {
        var displayError = "Please enter a "
        if username.text == "" {
            displayError += "username"
        } else if firstName.text == "" {
            displayError += "first name"
        } else if lastName.text == "" {
            displayError += "last name"
        } else if password.text == "" {
            displayError += "password"
        } else if email.text == "" {
            displayError += "n email"
        } else if confirmPassword.text == "" {
            displayError = "Please confirm password"
        } else if confirmPassword.text != password.text {
            displayError = "Passwords must match"
        }
        
        if displayError != "Please enter a " {
            displayAlert("Incomplete Form", displayError: displayError)
        } else {
            let user = PFUser()
            user["firstName"] = firstName.text
            user["lastName"] = lastName.text
            user.username = username.text
            user.password = password.text
            user.email = email.text
            var defaultImage = UIImage(named: "defaultPic")
            print(defaultImage)
            user["profileImage"] = PFFile(name: "profile.png", data: UIImageJPEGRepresentation(defaultImage!, 0.5)!)
            user.signUpInBackgroundWithBlock { (succeeded, signUpError) -> Void in
                
                if signUpError == nil {
                            UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseIn], animations: {
                                self.view.frame = CGRectOffset(self.view.frame, 0, UIScreen.mainScreen().bounds.height/3 - 10)
                                }, completion: nil)
                    
                
                    
                    let userAgreement = "Please make sure that you do not post any content that could be offensive to others and that you conduct yourself on this app in a friendly manner. Pixplore does not tolerate any form of bullying or offensive content. If you violate these rules, you may be permanently banned from this community"
                    self.displayAlertAccept("User Agreement", displayError: userAgreement)
                } else {
                    if let error = signUpError!.userInfo["error"] as? NSString {
                        displayError = error as String
                    } else {
                        displayError = "Please try again later"
                    }
                    self.displayAlert("Could not Sign Up", displayError: displayError)
                }
            }
        }
    }
    
    func displayAlertAccept(title: String, displayError: String) {
        let alert = UIAlertController(title: "User Agreement", message: displayError, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title:"Accept", style: UIAlertActionStyle.Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
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
