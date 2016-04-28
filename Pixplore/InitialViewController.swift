//
//  InitialViewController.swift
//  Pixplore
//
//  Created by Ali Shelton on 4/24/16.
//  Copyright © 2016 Mansi Shah. All rights reserved.
//

import UIKit
import Parse

class InitialViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(animated: Bool) {
        let currUser = PFUser.currentUser()
        if (currUser == nil) {
            self.performSegueWithIdentifier("toLogin", sender: self)
        }
        else {
           // let vc = self.storyboard?.instantiateViewControllerWithIdentifier("feedTaBVC") as! UITabBarController
           // self.presentViewController(vc, animated: true, completion: nil)
            self.performSegueWithIdentifier("toFeedFromInitial", sender: self)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
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
