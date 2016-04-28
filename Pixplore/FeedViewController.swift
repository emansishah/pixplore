//
//  FeedViewController.swift
//  Pixplore
//
//  Created by Mansi Shah on 4/2/16.
//  Copyright © 2016 Mansi Shah. All rights reserved.
//

import UIKit
import Parse
import LocationPickerViewController

struct Location {
    static var currLoc = CLLocation()
    static var isUsingCustom = false
}

struct Saved {
    static var hasSaved = false
}


class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, LocationPickerDelegate {
    
    //Post variables
    var imageNames = Array<PFFile>()
    var userNames = Array<String>()
    var numSaves = Array<Int>()
    var captions = Array<String>()
    var postObjects = Array<PFObject>()
    var refreshControl = UIRefreshControl()
    var sortbyType = ""
    var currLocation = CLLocation()
    var searchLocation = CLLocation()
    var isUsingCustomLocation = NSUserDefaults.standardUserDefaults().boolForKey("isUsingCustomLocation")
    var currentUser = PFUser.currentUser()
    var hasQueried = false
    
    @IBOutlet weak var currentNavigationItem: UINavigationItem!
    //var uploaderImage = UIImage()
    
    //Cocoa pod variables
    var sideBarImages = NSArray(array: [UIImage(named: "profileIcon")!, UIImage(named: "Door Opened-100")!])
    
    @IBOutlet weak var locationInfo: UINavigationItem!
    @IBOutlet weak var segmentView: UISegmentedControl!
    
    
    @IBAction func orderbySegmentButton(sender: AnyObject) {
        if segmentView.selectedSegmentIndex == 0 {
            sortbyType = "popular"
        } else {
            sortbyType = "new"
        }
        refresh()
    }
    
    @IBAction func newButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("upload", sender: self)
    }
    
    @IBAction func profileButton(sender: AnyObject) {
        let locationPicker = LocationPicker()
        locationPicker.delegate = self
        print("outside", self.searchLocation)
        locationPicker.addButtons()
        navigationController!.pushViewController(locationPicker, animated: true)
    }
    
    func locationDidPick(locationItem: LocationItem) {
        currLocation = CLLocation(latitude: locationItem.coordinate.latitude, longitude: locationItem.coordinate.longitude)
        print("DELEGATE LOCATION: %@", currLocation)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUsingCustomLocation")
        NSUserDefaults.standardUserDefaults().setDouble(locationItem.coordinate.latitude, forKey: "customLocationLatitude")
        NSUserDefaults.standardUserDefaults().setDouble(locationItem.coordinate.longitude, forKey: "customLocationLongitude")
        NSUserDefaults.standardUserDefaults().synchronize()
        Location.currLoc = currLocation
        Location.isUsingCustom = true
        self.collectionView.reloadData()
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //collection view setup
        collectionView.delegate = self
        collectionView.dataSource = self
        currentNavigationItem.titleView = segmentView
        currentNavigationItem.titleView?.tintColor = UIColor.whiteColor()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView?.addSubview(refreshControl)
        orderbySegmentButton(self)
        
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.alwaysBounceVertical = true
        
        
        //Grab user location at beginning
        if !isUsingCustomLocation {
            PFGeoPoint.geoPointForCurrentLocationInBackground {
                (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                if error == nil {
                    let userLoc = geoPoint!
                    self.currLocation = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
                    Location.currLoc = self.currLocation
                }
            }
        }else {
            let locULat = NSUserDefaults.standardUserDefaults().doubleForKey("customLocationLatitude")
            let locULon = NSUserDefaults.standardUserDefaults().doubleForKey("customLocationLongitude")
            if locULon != 0 && locULat != 0 {
                currLocation = CLLocation(latitude:locULat, longitude: locULon)
            }
        }
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUsingCustomLocation")
        NSUserDefaults.standardUserDefaults().setDouble(0, forKey: "customLocationLatitude")
        NSUserDefaults.standardUserDefaults().setDouble(0, forKey: "customLocationLongitude")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        //Refresh
        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        hasQueried = false
        //set collection view bounds
        collectionView.frame = self.view.bounds
        
//        //Swipe right
//        let cSelector: Selector = "sideMenu:"
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
//        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
//        view.addGestureRecognizer(rightSwipe)
        refresh()
    }
    
    func refresh() {
        getPosts()
        if self.refreshControl.refreshing {
            self.refreshControl.endRefreshing()
        }
        self.collectionView?.reloadData()
        self.collectionView.setContentOffset(CGPointMake(0, -40), animated: true)
    }
    
    func getPosts() {
        print(hasQueried)
        let query = PFQuery(className: "Photo")
        if (sortbyType == "popular") {
            query.orderByDescending("numberofSaves")
        } else {
            query.orderByDescending("createdAt")
        }
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("Successfully retrieved \(objects!.count) photos.")
                if let objects = objects {
//                    self.postObjects = objects
//                    self.collectionView.reloadData()
                    self.postObjects = Array<PFObject>()
                    for object in objects {
                        let picLocation = object["location"] as! PFGeoPoint
                        let picLoc:CLLocation = CLLocation(latitude: picLocation.latitude, longitude: picLocation.longitude)
                        let dist = self.currLocation.distanceFromLocation(picLoc)//self.currLocation.distanceFromLocation(picLoc)
                        let inputDist = round(dist*0.00621371)/10
                        if inputDist <= 25 {
                            self.postObjects.append(object)
                        }
                    }
                    self.collectionView.reloadData()
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if postObjects.count == 0 && !hasQueried{
            let label = UILabel()
            label.text = "No Posts Near This Location"
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont(name: "Raleway~SemiBold", size: 17)
            //label.center = self.collectionView.center
            collectionView.backgroundView = label
        }
        return postObjects.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FeedCollectionViewCell
        
        postObjects[indexPath.row]["photo"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                let tempImage = UIImage(data: imageData!)
                cell.locationImage.image = tempImage
                
                let postUser = self.postObjects[indexPath.item]["uploadingUser"] as! PFUser
                postUser.fetchIfNeededInBackgroundWithBlock {
                    (postt: PFObject?, error: NSError?) -> Void in
                    let userPic = postt?["profileImage"] as! PFFile?
                    print(userPic)
                    if (userPic != nil) {
                        userPic!.getDataInBackgroundWithBlock {
                            (data, error) -> Void in
                            if let data = data where error == nil {
                                let image = UIImage(data: data)
                                //self.uploaderImage = image!
                                
                                cell.profPicture.layer.cornerRadius = cell.profPicture.frame.height / 2
                                cell.profPicture.clipsToBounds = true
                                cell.profPicture.image = image
                                
                                cell.saveButton.layer.cornerRadius = cell.saveButton.frame.height/3.5
                                let date = self.postObjects[indexPath.item].createdAt! as! NSDate
                                let currentDate = NSDate()
                                let timeBetweenDates = currentDate.timeIntervalSinceDate(date)
                                let secondsInADay = 86400.0
                                let daysBetween = timeBetweenDates / secondsInADay
                                let days = Int(floor(daysBetween))
                                if (days == 1) {
                                    cell.daysAgoPosted.text = String(days) + " Day"
                                } else {
                                    cell.daysAgoPosted.text = String(days) + " Days"
                                }
                                
                                cell.userName.text = self.postObjects[indexPath.item]["username"] as? String
                                let saves = self.postObjects[indexPath.item]["numberofSaves"] as! Int
                                if (saves == 1) {
                                    cell.numSaves.text = String(saves) + " Save"
                                } else {
                                    cell.numSaves.text = String(saves) + " Saves"
                                }
                                cell.caption.text = self.postObjects[indexPath.item]["description"] as? String
                                cell.photoObject = self.postObjects[indexPath.row]
                                //distance info
                                print("every index", self.currLocation)
                                let picLocation = self.postObjects[indexPath.item]["location"] as! PFGeoPoint
                                let picLoc:CLLocation = CLLocation(latitude: picLocation.latitude, longitude: picLocation.longitude)
                                let dist = self.currLocation.distanceFromLocation(picLoc)//self.currLocation.distanceFromLocation(picLoc)
                                let inputDist = round(dist*0.00621371)/10
                                cell.distance.text = String(inputDist) + " Miles"
                                self.hasQueried = true
                            }
                        }
 
                    }
                }
                /**
                 Return cell
                 */
            
            }
            
        }
    
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width, CGFloat(432))
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toDetails", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetails" {
            let vc = segue.destinationViewController as! DetailsViewController
            var index = (sender as! NSIndexPath).item
            self.postObjects[index]["photo"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    vc.picture.image = UIImage(data: imageData!)!
                    let postUser = self.postObjects[index]["uploadingUser"] as! PFUser
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
            //vc.userImage = self.uploaderImage
            vc.caption = (self.postObjects[index]["description"] as! String)
            vc.userName = (self.postObjects[index]["username"] as! String)
            vc.numSaves = (self.postObjects[index]["numberofSaves"] as! Int)
            var date = self.postObjects[index].createdAt! as! NSDate
            var currentDate = NSDate()
            var timeBetweenDates = currentDate.timeIntervalSinceDate(date)
            var secondsInADay = 86400.0
            var daysBetween = timeBetweenDates / secondsInADay
            var days = Int(floor(daysBetween))
            vc.days = days as! Int
            vc.location = (self.postObjects[index]["location"] as! PFGeoPoint)
            vc.photoObject = (self.postObjects[index])
            let picLocation = self.postObjects[index]["location"] as! PFGeoPoint
            let picLoc:CLLocation = CLLocation(latitude: picLocation.latitude, longitude: picLocation.longitude)
            let dist = self.currLocation.distanceFromLocation(picLoc)
            let inputDist = round(dist*0.00621371)/10
            vc.distanceVal = String(inputDist) + " Miles"
        }
    }
    
//    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        var reusableview: UICollectionReusableView? = nil
//        if kind == .Footer {
//            reusableview = collectionView.dequeueReusableSupplementaryViewOfKind(.Footer, withReuseIdentifier: "FooterView", forIndexPath: indexPath)
//            if images.count > 0 {
//                reusableview!.hidden = true
//                reusableview!.frame = CGRectMake(0, 0, 0, 0)
//            }
//            else {
//                reusableview!.hidden = false
//                reusableview!.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
//            }
//        }
//        return reusableview!
//    }
    
}
