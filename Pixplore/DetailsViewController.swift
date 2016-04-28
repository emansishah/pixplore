//
//  DetailsViewController.swift
//  Pixplore
//
//  Created by Ali Shelton on 4/3/16.
//  Copyright © 2016 Mansi Shah. All rights reserved.
//

import UIKit
import MapKit
import Parse

class DetailsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var navBar: UINavigationItem!
    //Passed in variables
    var image = UIImage()
    var userImage = UIImage()
    var userName = ""
    var numSaves = 0
    var days = 0
    var location = PFGeoPoint()
    var caption = ""
    var photoObject: PFObject?
    var distanceVal = ""


    @IBOutlet weak var saveButton: UIButton!
    @IBAction func flagPressed(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        if (photoObject!["numberofFlags"] == nil) {
            photoObject!["numberofFlags"] = 1
            photoObject!.addUniqueObject(currentUser!, forKey: "usersFlagged")
            photoObject?.saveInBackgroundWithTarget(nil, selector: nil)
            displayAlert("Flagged Image", displayError: "This image has been flagged")
        } else {
            if (!photoObject!["usersFlagged"].containsObject(currentUser)) {
                let currFlags = self.photoObject!["numberofFlags"] as! Int
                photoObject!["numberofFlags"] = currFlags + 1
                photoObject!.addUniqueObject(currentUser!, forKey: "usersFlagged")
                photoObject?.saveInBackgroundWithTarget(nil, selector: nil)
            }
        }
    }
    
    //Location
    let locationManager = CLLocationManager()
    
    //Connections to storyboard
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet var navigationIcon: UIImageView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet var saves: UILabel!
    @IBOutlet var createdCaption: UILabel!
    
    @IBOutlet weak var navigateButton: UIButton!
    
    //Functions
    @IBAction func navigate(sender: AnyObject) {
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Destination"
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    @IBAction func openOnMap(sender: AnyObject) {
        
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        if (currentUser!["savedImages"] == nil || !currentUser!["savedImages"].containsObject(photoObject!)) {
            numSaves = photoObject!["numberofSaves"] as! Int + 1
            photoObject!["numberofSaves"] = numSaves
            currentUser?.addUniqueObject(photoObject!, forKey: "savedImages")
            currentUser?.saveInBackgroundWithBlock({ (success, error) in
                Saved.hasSaved = true
            })
            if (currentUser!["savedImages"] == nil) {
                self.saves.text = String(self.numSaves) + " Save"
            }
            else {
                self.saves.text = String(self.numSaves) + " Saves"
            }
        }
//        Saved.hasSaved = true
    }
    
    @IBAction func backFromDetails(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        self.saveButton.layer.cornerRadius = self.saveButton.frame.height/3
        self.navigateButton.layer.cornerRadius = self.navigateButton.frame.height/3
        self.picture.image = self.image
        self.username.text = self.userName
        if (self.numSaves == 1) {
            self.saves.text = String(self.numSaves) + " Save"
        } else {
            self.saves.text = String(self.numSaves) + " Saves"
        }
        self.createdCaption.text = self.caption
        if (self.days == 1) {
            self.date.text = String(self.days) + " day"
        } else {
            self.date.text = String(self.days) + " days"
        }
        self.profileImage.image = self.userImage
        self.profileImage.layer.cornerRadius = self.profileImage.frame.height/2
        self.profileImage.clipsToBounds = true
        self.distance.text = distanceVal
        self.map.mapType = .Standard
        
        //location
        locationManager.delegate = self
        
        navBar.title = ""
        var label = UILabel(frame: CGRect(x: (self.view.bounds.width - 200)/2, y: 0, width: 200, height: 100))
        label.text = "DETAILS"
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Raleway~SemiBold", size: 18)
        navBar.titleView = label
    }
    
    override func viewDidAppear(animated: Bool) {
        addAnnotation()
        centerLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAnnotation() {
        var photoLocation = photoObject!["location"]
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(photoLocation.latitude, photoLocation.longitude)
        self.map.addAnnotation(annotation)
        print("Location Added: ", photoLocation)
    }
    
    func centerLocation() {
        var location = CLLocationCoordinate2D(latitude: self.location.latitude, longitude: self.location.longitude)
        let span = MKCoordinateSpanMake(10, 10)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: false)
    }
    
    func displayAlert(title: String, displayError: String) {
        let alert = UIAlertController(title: title, message: displayError, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {action in self.dismissViewControllerAnimated(true, completion: nil)}))
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
