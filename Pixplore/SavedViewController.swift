//
//  SavedViewController.swift
//  Pixplore
//
//  Created by Mansi Shah on 4/9/16.
//  Copyright © 2016 Mansi Shah. All rights reserved.
//

import UIKit
import Parse

class SavedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var navBar: UINavigationItem!
    var savedObjects = Array<PFObject>()
    var refreshControl = UIRefreshControl()
    var sortbyType = "createdAt"
    
    //@IBOutlet weak var segmentView: UISegmentedControl!
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.alwaysBounceVertical = true
        // Do any additional setup after loading the view.
        navBar.title = ""
        var label = UILabel(frame: CGRect(x: (self.view.bounds.width - 200)/2, y: 0, width: 200, height: 100))
        label.text = "SAVED"
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Raleway~SemiBold", size: 18)
        navBar.titleView = label
        refreshFeed()
    }
    
    override func viewDidAppear(animated: Bool) {
        if Saved.hasSaved {
            refreshFeed()
            Saved.hasSaved = false
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.savedObjects.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell1", forIndexPath: indexPath) as! SavedCollectionViewCell
        
        self.savedObjects[indexPath.row]["photo"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                let tempImage = UIImage(data: imageData!)
                cell.savedImage.image = tempImage
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("saveToDetail", sender: indexPath)
    }
    
    func refreshFeed() {
        getPosts()
        if self.refreshControl.refreshing {
            self.refreshControl.endRefreshing()
        }
        //self.collectionView.reloadData()
    }
    
    func getPosts() {
        let currentUser = PFUser.currentUser()
        print(currentUser)
        var tempSaved = currentUser!["savedImages"]
        var saved = Array<PFObject>()
        if tempSaved != nil {
            saved = tempSaved as! Array<PFObject>
        }
        let query = PFQuery(className: "Photo")
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("Successfully retrieved \(objects!.count) photos.")
                if let objects = objects {
                    if objects.count == 0 {
                        print("there is nothing to display")
                    }
                    else {
                        for object in objects {
                            if tempSaved != nil {
                                if saved.contains(object) && !self.savedObjects.contains(object) {
                                    self.savedObjects.insert(object, atIndex: 0)
                                }
                            }
                        }

                    }
                    self.collectionView.reloadData()
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveToDetail" {
            let vc = segue.destinationViewController as! DetailsViewController
            var index = (sender as! NSIndexPath).item
            self.savedObjects[index]["photo"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    vc.picture.image = UIImage(data: imageData!)!
                    let postUser = self.savedObjects[index]["uploadingUser"] as! PFUser
                    postUser.fetchIfNeededInBackgroundWithBlock {
                        (postt: PFObject?, error: NSError?) -> Void in
                        let userPic = postt?["profileImage"] as! PFFile!
                        userPic.getDataInBackgroundWithBlock {
                            (data, error) -> Void in
                            if let data = data where error == nil {
                                let tempImage = UIImage(data: data)
                                //self.uploaderImage = image!
                                vc.profileImage.image = tempImage
                            }
                        }
                    }
                }
            }
            vc.caption = (self.savedObjects[index]["description"] as! String)
            vc.userName = (self.savedObjects[index]["username"] as! String)
            vc.numSaves = (self.savedObjects[index]["numberofSaves"] as! Int)
            vc.location = (self.savedObjects[index]["location"] as! PFGeoPoint)
            let currLocation = Location.currLoc
            let picLocation = self.savedObjects[index]["location"] as! PFGeoPoint
            let picLoc:CLLocation = CLLocation(latitude: picLocation.latitude, longitude: picLocation.longitude)
            let dist = currLocation.distanceFromLocation(picLoc)
            let inputDist = round(dist*0.00621371)/10
            vc.distanceVal = String(inputDist) + " Miles"
            vc.photoObject = (self.savedObjects[index])
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
